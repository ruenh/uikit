"""
Authentication router for Telegram initData validation.

Implements HMAC-SHA256 validation according to Telegram Mini Apps documentation.
Source: https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app
"""

from fastapi import APIRouter, HTTPException, Depends, Response
import hmac
import hashlib
from urllib.parse import parse_qsl
from datetime import datetime
import asyncpg
import json
import logging

from app.config import settings
from app.database import get_db_pool
from app.auth import create_access_token
from app.models import AuthRequest, AuthResponse, UserInfo

router = APIRouter()
logger = logging.getLogger(__name__)


def validate_init_data(init_data: str, bot_token: str, max_age_seconds: int = 86400) -> dict:
    """
    Validate Telegram initData using HMAC-SHA256 and check expiration.
    
    Source: Telegram Mini Apps documentation
    https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app
    
    Algorithm:
    1. Parse initData query string
    2. Extract hash value
    3. Check auth_date (TTL validation)
    4. Create data_check_string from sorted key=value pairs
    5. Create secret_key = HMAC-SHA256("WebAppData", bot_token)
    6. Calculate hash = HMAC-SHA256(data_check_string, secret_key)
    7. Compare hashes (constant-time)
    
    Args:
        init_data: Raw initData string from Telegram
        bot_token: Bot token for HMAC validation
        max_age_seconds: Maximum age of initData (default: 86400 = 24 hours)
                        Production recommendation: 300-600 seconds (5-10 minutes)
    
    Raises:
        ValueError: If validation fails or initData is expired
    """
    try:
        parsed = dict(parse_qsl(init_data))
        hash_value = parsed.pop('hash', None)
        
        if not hash_value:
            raise ValueError("No hash in initData")
        
        # Check auth_date (TTL validation)
        auth_date = parsed.get('auth_date')
        if not auth_date:
            raise ValueError("No auth_date in initData")
        
        try:
            auth_timestamp = int(auth_date)
        except ValueError:
            raise ValueError("Invalid auth_date format")
        
        current_timestamp = int(datetime.utcnow().timestamp())
        age_seconds = current_timestamp - auth_timestamp
        
        if age_seconds > max_age_seconds:
            raise ValueError(f"initData expired (age: {age_seconds}s, max: {max_age_seconds}s)")
        
        if age_seconds < 0:
            raise ValueError("auth_date is in the future")
        
        # Create data check string
        data_check_string = '\n'.join(
            f"{k}={v}" for k, v in sorted(parsed.items())
        )
        
        # Create secret key
        secret_key = hmac.new(
            key=b"WebAppData",
            msg=bot_token.encode(),
            digestmod=hashlib.sha256
        ).digest()
        
        # Calculate hash
        calculated_hash = hmac.new(
            key=secret_key,
            msg=data_check_string.encode(),
            digestmod=hashlib.sha256
        ).hexdigest()
        
        # Compare hashes (constant-time)
        if not hmac.compare_digest(calculated_hash, hash_value):
            raise ValueError("Invalid hash")
        
        return parsed
    except Exception as e:
        raise ValueError(f"Validation failed: {str(e)}")


@router.post("/validate", response_model=AuthResponse)
async def validate_auth(
    request: AuthRequest,
    response: Response,
    pool: asyncpg.Pool = Depends(get_db_pool)
) -> AuthResponse:
    """
    Validate Telegram initData and set session cookie.
    
    Steps:
    1. Validate initData HMAC
    2. Parse user data
    3. Upsert user in database
    4. Generate JWT token
    5. Set HttpOnly cookie
    6. Return user info
    
    Source: FastAPI cookie documentation
    Verified: response.set_cookie() with httponly, secure, samesite parameters
    """
    try:
        # Validate initData with configurable TTL
        validated_data = validate_init_data(
            request.initData, 
            settings.BOT_TOKEN,
            settings.INIT_DATA_MAX_AGE_SECONDS
        )
        logger.info("InitData validated successfully")
        
        # Parse user data
        user_data = json.loads(validated_data.get('user', '{}'))
        telegram_id = user_data.get('id')
        
        if not telegram_id:
            raise HTTPException(status_code=400, detail="No user ID in initData")
        
        # Upsert user in database
        async with pool.acquire() as conn:
            user = await conn.fetchrow("""
                INSERT INTO users (telegram_id, first_name, last_name, username)
                VALUES ($1, $2, $3, $4)
                ON CONFLICT (telegram_id) DO UPDATE
                SET first_name = EXCLUDED.first_name,
                    last_name = EXCLUDED.last_name,
                    username = EXCLUDED.username,
                    updated_at = NOW()
                RETURNING id, telegram_id, first_name, last_name, username
            """, telegram_id, user_data.get('first_name'), 
                user_data.get('last_name'), user_data.get('username'))
        
        # Generate JWT token
        token_data = {
            "user_id": user['id'],
            "telegram_id": user['telegram_id'],
        }
        access_token = create_access_token(data=token_data)
        
        # Set HttpOnly cookie
        # Source: FastAPI cookie documentation (verified via MCP)
        # Cookie Policy:
        # - Domain: Configured via COOKIE_DOMAIN (e.g., .yourdomain.com for subdomain sharing)
        # - Path: / (available to all routes)
        # - SameSite: Configured via COOKIE_SAMESITE (e.g., "none" for cross-domain)
        # - Secure: Configured via COOKIE_SECURE (MUST be True in production with HTTPS)
        # - max_age: Configured via COOKIE_MAX_AGE (seconds, e.g., 86400 = 24 hours)
        response.set_cookie(
            key="session",
            value=access_token,
            httponly=True,  # Prevents JavaScript access
            secure=settings.COOKIE_SECURE,  # HTTPS only (MUST be True in production)
            samesite=settings.COOKIE_SAMESITE,  # "none" for cross-domain
            max_age=settings.COOKIE_MAX_AGE,  # 86400 seconds = 24 hours
            domain=settings.COOKIE_DOMAIN,  # For subdomain sharing
            path="/",  # Available to all routes
        )
        
        logger.info(f"User {telegram_id} authenticated successfully")
        
        return AuthResponse(
            success=True,
            user=UserInfo(**dict(user))
        )
    
    except ValueError as e:
        logger.warning(f"InitData validation failed: {e}")
        raise HTTPException(status_code=401, detail="Invalid authentication data")
    except Exception as e:
        logger.error(f"Unexpected error during auth: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")
