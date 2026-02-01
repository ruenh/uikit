"""
TMA Studio FastAPI Backend

Main application with CORS, lifespan management, and router registration.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import asyncpg
import logging

from app.config import settings
from app import database
from app.routers import auth, prefs, health

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    # Startup: Create connection pool
    try:
        pool = await asyncpg.create_pool(
            dsn=settings.DATABASE_URL,
            min_size=5,
            max_size=20,
            command_timeout=60,
        )
        database.set_db_pool(pool)
        logger.info("Database connection pool created")
    except Exception as e:
        logger.error(f"Failed to create database pool: {e}")
        raise
    
    yield
    
    # Shutdown: Close connection pool
    await database.close_db_pool()
    logger.info("Database connection pool closed")


app = FastAPI(
    title="TMA Studio API",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS configuration for cookie-based auth
# Source: FastAPI CORS documentation
# Verified: allow_credentials=True requires explicit origins (not "*")
# CRITICAL RULE: When allow_credentials=True, allow_origins MUST be explicit list
# Using "*" with credentials will fail in browsers (CORS policy violation)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,  # Must be explicit list, e.g., ["https://app.yourdomain.com"]
    allow_credentials=True,  # Required for cookies
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(prefs.router, prefix="/api/preferences", tags=["preferences"])
app.include_router(health.router, prefix="/api", tags=["health"])
