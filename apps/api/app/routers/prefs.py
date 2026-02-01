"""
Preferences router for user preferences management.

Handles GET and PUT operations for user preferences with cookie-based authentication.
"""

from fastapi import APIRouter, HTTPException, Depends, Cookie
from typing import Optional
import asyncpg
import logging

from app.database import get_db_pool
from app.auth import extract_user_id_from_cookie
from app.models import PreferencesModel

router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("", response_model=PreferencesModel)
async def get_preferences(
    session: Optional[str] = Cookie(None),
    pool: asyncpg.Pool = Depends(get_db_pool)
) -> PreferencesModel:
    """
    Get user preferences from database.
    
    Requires authentication via session cookie.
    Returns default preferences if none exist for the user.
    """
    if not session:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    try:
        user_id = extract_user_id_from_cookie(session)
        
        async with pool.acquire() as conn:
            prefs = await conn.fetchrow("""
                SELECT theme_mode, reduced_motion
                FROM user_preferences
                WHERE user_id = $1
            """, user_id)
            
            if not prefs:
                # Return defaults if no preferences exist
                return PreferencesModel()
            
            return PreferencesModel(**dict(prefs))
    
    except ValueError as e:
        logger.warning(f"Invalid session cookie: {e}")
        raise HTTPException(status_code=401, detail="Invalid session")
    except Exception as e:
        logger.error(f"Error getting preferences: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")


@router.put("", response_model=PreferencesModel)
async def update_preferences(
    prefs: PreferencesModel,
    session: Optional[str] = Cookie(None),
    pool: asyncpg.Pool = Depends(get_db_pool)
) -> PreferencesModel:
    """
    Update user preferences in database.
    
    Requires authentication via session cookie.
    Uses UPSERT to create or update preferences.
    """
    if not session:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    try:
        user_id = extract_user_id_from_cookie(session)
        
        async with pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO user_preferences (user_id, theme_mode, reduced_motion)
                VALUES ($1, $2, $3)
                ON CONFLICT (user_id) DO UPDATE
                SET theme_mode = EXCLUDED.theme_mode,
                    reduced_motion = EXCLUDED.reduced_motion,
                    updated_at = NOW()
            """, user_id, prefs.theme_mode, prefs.reduced_motion)
        
        logger.info(f"Updated preferences for user {user_id}")
        return prefs
    
    except ValueError as e:
        logger.warning(f"Invalid session cookie: {e}")
        raise HTTPException(status_code=401, detail="Invalid session")
    except Exception as e:
        logger.error(f"Error updating preferences: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")
