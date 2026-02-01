"""
Authentication utilities for JWT token management.

Uses python-jose for JWT encoding/decoding with HS256 algorithm.
Source: python-jose documentation (verified via MCP)
"""

from datetime import datetime, timedelta
from jose import JWTError, jwt
from app.config import settings


def create_access_token(data: dict) -> str:
    """
    Create JWT access token.
    
    Library: python-jose[cryptography]
    Algorithm: HS256
    Expiration: Configurable via JWT_EXPIRATION_HOURS (default: 24 hours)
    
    Source: python-jose documentation
    Verified: jwt.encode() with HS256 algorithm and exp claim
    
    Args:
        data: Dictionary of claims to encode in the token
        
    Returns:
        Encoded JWT token string
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(hours=settings.JWT_EXPIRATION_HOURS)
    
    to_encode.update({
        "exp": expire,
        "iat": datetime.utcnow()
    })
    
    encoded_jwt = jwt.encode(
        to_encode,
        settings.JWT_SECRET,
        algorithm=settings.JWT_ALGORITHM
    )
    
    return encoded_jwt


def decode_access_token(token: str) -> dict:
    """
    Decode and validate JWT token.
    
    Source: python-jose documentation
    Verified: jwt.decode() validates signature and expiration automatically
    
    Args:
        token: JWT token string to decode
        
    Returns:
        Dictionary of decoded claims
        
    Raises:
        ValueError: If token is invalid or expired (wraps JWTError)
    """
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET,
            algorithms=[settings.JWT_ALGORITHM]
        )
        return payload
    except JWTError as e:
        raise ValueError(f"Invalid token: {str(e)}")


def extract_user_id_from_cookie(session_cookie: str) -> int:
    """
    Extract user ID from session cookie (JWT).
    
    Args:
        session_cookie: JWT token from cookie
    
    Returns:
        user_id from JWT claims
    
    Raises:
        ValueError: If token is invalid or missing user_id claim
    """
    payload = decode_access_token(session_cookie)
    
    user_id = payload.get("user_id")
    if not user_id:
        raise ValueError("Token missing user_id claim")
    
    return int(user_id)
