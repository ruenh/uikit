"""
Pydantic models for request/response validation.

Uses Pydantic v2 for data validation and serialization.
"""

from pydantic import BaseModel
from typing import Optional


class AuthRequest(BaseModel):
    """Request model for authentication endpoint"""
    initData: str


class UserInfo(BaseModel):
    """User information model"""
    id: int
    telegram_id: int
    first_name: str
    last_name: Optional[str] = None
    username: Optional[str] = None


class AuthResponse(BaseModel):
    """Response model for authentication endpoint"""
    success: bool
    user: UserInfo


class PreferencesModel(BaseModel):
    """User preferences model"""
    theme_mode: str = "premium"
    reduced_motion: bool = False


class HealthResponse(BaseModel):
    """Health check response model"""
    status: str
    database: Optional[str] = None
    error: Optional[str] = None
