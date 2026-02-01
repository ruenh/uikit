"""
Database connection pool management.

Provides dependency injection for database access.
"""

import asyncpg
from typing import Optional

# Global connection pool (initialized in main.py lifespan)
_db_pool: Optional[asyncpg.Pool] = None


def get_db_pool() -> asyncpg.Pool:
    """
    Dependency for database pool.
    
    Returns:
        asyncpg.Pool: Database connection pool
        
    Raises:
        RuntimeError: If pool is not initialized
    """
    if _db_pool is None:
        raise RuntimeError("Database pool not initialized")
    return _db_pool


def set_db_pool(pool: asyncpg.Pool) -> None:
    """
    Set the global database pool.
    
    Called by main.py during lifespan startup.
    
    Args:
        pool: Database connection pool
    """
    global _db_pool
    _db_pool = pool


async def close_db_pool() -> None:
    """
    Close the global database pool.
    
    Called by main.py during lifespan shutdown.
    """
    global _db_pool
    if _db_pool:
        await _db_pool.close()
        _db_pool = None
