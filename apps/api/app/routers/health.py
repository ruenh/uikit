"""
Health check router for monitoring.

Provides a simple health check endpoint that verifies database connectivity.
No authentication required.
"""

from fastapi import APIRouter, Depends
import asyncpg
import logging

from app.database import get_db_pool
from app.models import HealthResponse

router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("/health", response_model=HealthResponse)
async def health_check(pool: asyncpg.Pool = Depends(get_db_pool)) -> HealthResponse:
    """
    Health check endpoint - no authentication required.
    
    Verifies:
    - API is running
    - Database connection is working
    
    Returns:
        HealthResponse with status and database state
    """
    try:
        async with pool.acquire() as conn:
            await conn.fetchval("SELECT 1")
        return HealthResponse(status="healthy", database="connected")
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return HealthResponse(status="unhealthy", error=str(e))
