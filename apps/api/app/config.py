"""
Configuration management using pydantic-settings.

All settings are loaded from environment variables.
"""

from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    # Telegram
    BOT_TOKEN: str
    
    # Database
    DATABASE_URL: str
    
    # JWT
    JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_HOURS: int = 24
    
    # InitData validation
    # INIT_DATA_MAX_AGE_SECONDS: Maximum age of initData before rejection
    # Default: 86400 (24 hours) for demo/development
    # Production recommendation: 300-600 seconds (5-10 minutes) for tighter security
    # Rationale: Shorter TTL reduces replay attack window, but may cause issues
    # if users have clock skew or slow networks. Balance security vs UX.
    INIT_DATA_MAX_AGE_SECONDS: int = 86400
    
    # CORS - MUST be explicit origins for credentials (not "*")
    # Source: FastAPI CORS documentation
    # Verified: allow_credentials=True requires explicit allow_origins list
    ALLOWED_ORIGINS: List[str]
    
    # Cookie settings
    # COOKIE_DOMAIN: Use ".yourdomain.com" to share cookies between app.* and api.*
    # Empty string ("") means same-domain only (not shared across subdomains)
    COOKIE_DOMAIN: str = ".yourdomain.com"
    
    # COOKIE_SECURE: MUST be True in production (HTTPS only)
    # Source: OWASP Secure Cookie guidelines
    COOKIE_SECURE: bool = True
    
    # COOKIE_SAMESITE: MUST be "none" for cross-domain cookies
    # Rule: SameSite=None REQUIRES Secure=True (enforced by browsers)
    # Source: MDN SameSite cookie documentation
    COOKIE_SAMESITE: str = "none"
    
    # COOKIE_MAX_AGE: Use max_age (seconds) instead of expires (datetime)
    # Rationale: max_age is simpler and more reliable across timezones
    # 86400 seconds = 24 hours
    COOKIE_MAX_AGE: int = 86400
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
