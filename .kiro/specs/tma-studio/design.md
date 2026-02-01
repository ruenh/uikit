# Design Document: TMA Studio

## MVP Scope (Phase 1) - Production Ready

**Goal**: Full-stack Telegram Mini App showcase with real backend, deployable to production VDS.

**MVP Deliverables**:
1. **Frontend** (5 pages): Home, Buttons, Popups, Theme, Navigation + minimal Integrations page
2. **Backend** (FastAPI): Real initData validation + preferences storage in Postgres
3. **Bot** (aiogram 3.x): /start command with web_app button
4. **Database** (Supabase Postgres): Users + preferences tables
5. **Deployment**: Production-ready on VDS Ubuntu 24.04 + Nginx + domain

**MVP Flow (End-to-End)**:
1. User opens bot → clicks web_app button
2. Telegram loads Mini App with initData
3. Mini App sends initData to API
4. API validates initData (HMAC-SHA256) → returns user + session cookie
5. Mini App gets/updates preferences via API (authenticated)
6. Preferences persist in database, survive page reload

**Authentication Method**: HttpOnly cookies (secure, no localStorage exposure)
- API sets HttpOnly cookie on successful auth
- Frontend includes credentials in fetch requests
- CORS configured with `allow_credentials=True`

**Deployment Domains**:
- `app.yourdomain.com` → Frontend (Astro static files via Nginx)
- `api.yourdomain.com` → Backend (FastAPI via Nginx reverse proxy)
- Bot runs as systemd service on same VDS

**Definition of Done (MVP)**:
- [ ] Bot opens Mini App in Telegram
- [ ] API validates initData and returns user info
- [ ] Preferences save/load from database
- [ ] Theme persists across page reload (from DB)
- [ ] No console errors in Telegram WebView
- [ ] Deployed on VDS with HTTPS (Let's Encrypt)
- [ ] Health check endpoint responds
- [ ] Smoke test passes: bot → auth → prefs → reload → prefs restored


## Phase 2 Scope (Showcase Expansion)

**Additional Pages**:
- Haptics demo
- Viewport & Safe Area Lab
- Motion Showcase (Motion.dev animations)
- Forms page
- Cards & Lists page
- Deep links scenarios

**Quality Improvements**:
- Unit tests (frontend + backend)
- Property-based tests (optional)
- Lighthouse/Web Vitals optimization
- Performance targets: FCP < 2s, TTI < 4s on 3G
- Image optimization (WebP/AVIF with srcset)

## Overview

TMA Studio is a production-ready Telegram Mini App showcase demonstrating best practices with real backend integration. MVP includes full authentication flow, database persistence, and VDS deployment.

**Key Design Principles**:
1. **MCP-First Verification**: All technical decisions verified through official documentation
2. **Production-Ready MVP**: Real backend, real database, real deployment
3. **Premium Design**: astro.build-inspired with gradients, glow, glass effects
4. **Telegram-Native**: Deep WebApp API integration with graceful fallbacks
5. **Security-First**: Server-side initData validation, HttpOnly cookies, no secrets in code
6. **Extensible**: Clean architecture ready for Phase 2 expansion

**Technology Stack (Verified via MCP)**:
- **Frontend**: Astro 5.x + Svelte 5.x + Tailwind CSS v4 (CSS-first config)
- **Backend**: FastAPI + asyncpg + python-jose[cryptography]
- **Database**: Supabase Postgres with connection pooling
- **Bot**: aiogram 3.x with InlineKeyboardButton and WebAppInfo
- **Deployment**: Ubuntu 24.04 + Nginx + Let's Encrypt + systemd
- **Telegram**: Official telegram-web-app.js from CDN


## Architecture

### System Architecture (MVP)

```mermaid
graph TB
    User[Telegram User]
    TelegramClient[Telegram Client]
    Bot[aiogram Bot]
    WebApp[Astro Web App<br/>app.yourdomain.com]
    API[FastAPI Backend<br/>api.yourdomain.com]
    DB[(Supabase Postgres)]
    Nginx[Nginx Reverse Proxy]
    
    User -->|/start command| Bot
    Bot -->|web_app button| TelegramClient
    TelegramClient -->|loads with initData| WebApp
    WebApp -->|POST /api/auth/validate| Nginx
    Nginx -->|proxy_pass| API
    API -->|HMAC-SHA256 validation| API
    API -->|user CRUD| DB
    API -->|Set-Cookie: session| WebApp
    WebApp -->|GET/PUT /api/preferences<br/>Cookie: session| Nginx
    Nginx -->|proxy_pass| API
    API -->|prefs CRUD| DB
```

### Deployment Architecture (VDS)

```
VDS Ubuntu 24.04
├── Nginx (port 80/443)
│   ├── app.yourdomain.com → /var/www/tma-studio/dist (static files)
│   └── api.yourdomain.com → proxy_pass http://127.0.0.1:8000
├── FastAPI (port 8000)
│   └── systemd service: tma-studio-api.service
├── Bot (aiogram)
│   └── systemd service: tma-studio-bot.service
└── Supabase Postgres (remote or local)
```

### Monorepo Structure

```
tma-studio/
├── apps/
│   ├── web/                    # Astro + Svelte + Tailwind (MVP)
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── islands/    # Interactive Svelte components
│   │   │   │   │   ├── ThemeSwitcher.svelte
│   │   │   │   │   ├── ButtonDemo.svelte
│   │   │   │   │   ├── PopupDemo.svelte
│   │   │   │   │   └── IntegrationsDemo.svelte
│   │   │   │   └── ui/         # Static Astro components
│   │   │   │       ├── DemoCard.astro
│   │   │   │       └── NavigationTile.astro
│   │   │   ├── layouts/
│   │   │   │   └── Layout.astro
│   │   │   ├── pages/          # MVP pages
│   │   │   │   ├── index.astro
│   │   │   │   ├── buttons.astro
│   │   │   │   ├── popups.astro
│   │   │   │   ├── theme.astro
│   │   │   │   ├── navigation.astro
│   │   │   │   └── integrations.astro
│   │   │   ├── lib/
│   │   │   │   ├── tg.ts       # Telegram adapter (with fallbacks)
│   │   │   │   ├── api.ts      # API client (real HTTP calls)
│   │   │   │   └── theme.ts    # Theme management
│   │   │   └── styles/
│   │   │       └── global.css  # Tailwind CSS v4 + CSS variables
│   │   ├── public/
│   │   ├── astro.config.mjs
│   │   └── package.json
│   │
│   ├── api/                    # FastAPI backend (MVP)
│   │   ├── app/
│   │   │   ├── main.py         # FastAPI app + CORS + lifespan
│   │   │   ├── config.py       # Settings from env
│   │   │   ├── database.py     # asyncpg connection pool
│   │   │   ├── auth.py         # JWT + initData validation
│   │   │   ├── models.py       # Pydantic models
│   │   │   └── routers/
│   │   │       ├── auth.py     # POST /api/auth/validate
│   │   │       ├── prefs.py    # GET/PUT /api/preferences
│   │   │       └── health.py   # GET /api/health
│   │   ├── migrations/
│   │   │   └── 001_initial.sql # Database schema
│   │   ├── requirements.txt
│   │   └── .env.example
│   │
│   └── bot/                    # aiogram bot (MVP)
│       ├── bot.py              # Main bot file
│       ├── requirements.txt
│       └── .env.example
│
├── deploy/
│   ├── nginx/
│   │   ├── app.conf            # Nginx config for app.yourdomain.com
│   │   └── api.conf            # Nginx config for api.yourdomain.com
│   ├── systemd/
│   │   ├── tma-studio-api.service
│   │   └── tma-studio-bot.service
│   └── setup.sh                # VDS setup script
│
├── docs/
│   ├── architecture.md
│   ├── deployment.md           # VDS deployment guide
│   └── telegram-standards.md
│
├── .env.example
└── README.md
```


## API Contracts (MVP)

### Authentication Flow

**Endpoint**: `POST /api/auth/validate`

**Purpose**: Validate Telegram initData and establish authenticated session

**Request**:
```json
{
  "initData": "query_id=...&user=%7B%22id%22%3A123...&auth_date=...&hash=..."
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "user": {
    "id": 1,
    "telegram_id": 123456789,
    "first_name": "John",
    "last_name": "Doe",
    "username": "johndoe"
  }
}
```

**Headers** (Response):
```
Set-Cookie: session=<jwt_token>; HttpOnly; Secure; SameSite=None; Path=/; Max-Age=86400
```

**Error Response** (401 Unauthorized):
```json
{
  "detail": "Invalid authentication data"
}
```

**Implementation Notes**:
- Validates initData using HMAC-SHA256 with bot token
- Creates/updates user record in database
- Generates JWT token with user_id claim
- Sets HttpOnly cookie (secure, not accessible via JavaScript)
- Cookie expires in 24 hours

---

### Get Preferences

**Endpoint**: `GET /api/preferences`

**Purpose**: Retrieve user preferences from database

**Authentication**: Required (session cookie)

**Response** (200 OK):
```json
{
  "theme_mode": "premium",
  "reduced_motion": false
}
```

**Error Response** (401 Unauthorized):
```json
{
  "detail": "Not authenticated"
}
```

---

### Update Preferences

**Endpoint**: `PUT /api/preferences`

**Purpose**: Update user preferences in database

**Authentication**: Required (session cookie)

**Request**:
```json
{
  "theme_mode": "native",
  "reduced_motion": true
}
```

**Response** (200 OK):
```json
{
  "theme_mode": "native",
  "reduced_motion": true
}
```

---

### Health Check

**Endpoint**: `GET /api/health`

**Purpose**: Check API and database health

**Authentication**: None

**Response** (200 OK):
```json
{
  "status": "healthy",
  "database": "connected"
}
```

**Error Response** (500 Internal Server Error):
```json
{
  "status": "unhealthy",
  "error": "Database connection failed"
}
```


## Components and Implementation

### 1. Telegram Adapter (tg.ts)

**Purpose**: Single point of access for Telegram WebApp API with graceful fallbacks

**Key Features**:
- Availability checks for all methods
- Browser mode fallbacks (console warnings, native alert/confirm)
- Event listeners for theme/viewport changes
- Reactive CSS variable updates

**Implementation**: See full code in previous design.md (lines 200-400)

**Critical Rules**:
- ALL Telegram API calls MUST go through this adapter
- MUST handle absence of Telegram environment
- MUST provide console warnings when API unavailable
- MUST listen to `themeChanged` and `viewportChanged` events

---

### 2. API Client (api.ts)

**Purpose**: HTTP client for backend communication with cookie-based auth

**Implementation**:
```typescript
// apps/web/src/lib/api.ts

const API_BASE_URL = import.meta.env.PUBLIC_API_URL || 'https://api.yourdomain.com';

interface AuthResponse {
  success: boolean;
  user: {
    id: number;
    telegram_id: number;
    first_name: string;
    last_name?: string;
    username?: string;
  };
}

interface PreferencesResponse {
  theme_mode: 'native' | 'premium' | 'mixed';
  reduced_motion: boolean;
}

export const api = {
  auth: {
    validate: async (initData: string): Promise<AuthResponse> => {
      const response = await fetch(`${API_BASE_URL}/api/auth/validate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include', // Include cookies
        body: JSON.stringify({ initData }),
      });
      
      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.detail || `Auth failed: ${response.status}`);
      }
      
      return response.json();
    },
  },
  
  preferences: {
    get: async (): Promise<PreferencesResponse> => {
      const response = await fetch(`${API_BASE_URL}/api/preferences`, {
        credentials: 'include', // Include cookies
      });
      
      if (!response.ok) {
        throw new Error(`Failed to get preferences: ${response.status}`);
      }
      
      return response.json();
    },
    
    update: async (prefs: Partial<PreferencesResponse>): Promise<PreferencesResponse> => {
      const response = await fetch(`${API_BASE_URL}/api/preferences`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include', // Include cookies
        body: JSON.stringify(prefs),
      });
      
      if (!response.ok) {
        throw new Error(`Failed to update preferences: ${response.status}`);
      }
      
      return response.json();
    },
  },
  
  health: {
    check: async (): Promise<{ status: string }> => {
      const response = await fetch(`${API_BASE_URL}/api/health`);
      return response.json();
    },
  },
};
```

**Critical**: `credentials: 'include'` is REQUIRED for cookie-based auth

---

### 3. Theme Management (theme.ts)

**Purpose**: Theme switching with database sync

**Implementation**:
```typescript
// apps/web/src/lib/theme.ts

import { api } from './api';

export type ThemeMode = 'native' | 'premium' | 'mixed';

export const theme = {
  current: 'premium' as ThemeMode,
  
  set: async (mode: ThemeMode): Promise<void> => {
    try {
      theme.current = mode;
      document.documentElement.setAttribute('data-theme', mode);
      
      // Sync to backend (if authenticated)
      try {
        await api.preferences.update({ theme_mode: mode });
      } catch (error) {
        console.warn('[Theme] Failed to sync to backend:', error);
        // Continue anyway - theme still works locally
      }
    } catch (error) {
      console.error('[Theme] Failed to set theme:', error);
      document.documentElement.setAttribute('data-theme', 'premium');
    }
  },
  
  load: async (): Promise<ThemeMode> => {
    try {
      const prefs = await api.preferences.get();
      return prefs.theme_mode;
    } catch (error) {
      console.warn('[Theme] Failed to load from backend, using default');
      return 'premium';
    }
  },
  
  init: async (): Promise<void> => {
    const mode = await theme.load();
    theme.current = mode;
    document.documentElement.setAttribute('data-theme', mode);
  },
};
```


### 4. FastAPI Backend (Complete Implementation)

**Main Application**:
```python
# apps/api/app/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import asyncpg
import logging

from app.config import settings
from app.routers import auth, prefs, health

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global connection pool
db_pool: asyncpg.Pool = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    global db_pool
    
    # Startup: Create connection pool
    try:
        db_pool = await asyncpg.create_pool(
            dsn=settings.DATABASE_URL,
            min_size=5,
            max_size=20,
            command_timeout=60,
        )
        logger.info("Database connection pool created")
    except Exception as e:
        logger.error(f"Failed to create database pool: {e}")
        raise
    
    yield
    
    # Shutdown: Close connection pool
    if db_pool:
        await db_pool.close()
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

def get_db_pool() -> asyncpg.Pool:
    """Dependency for database pool"""
    return db_pool
```

**Configuration**:
```python
# apps/api/app/config.py

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
```

**Authentication Module**:
```python
# apps/api/app/auth.py

from datetime import datetime, timedelta
from jose import JWTError, jwt
from app.config import settings

def create_access_token(data: dict) -> str:
    """
    Create JWT access token.
    
    Library: python-jose[cryptography]
    Algorithm: HS256
    Expiration: 24 hours (configurable)
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
    
    Raises:
        JWTError: If token is invalid or expired
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
        ValueError: If token is invalid or missing user_id
    """
    payload = decode_access_token(session_cookie)
    
    user_id = payload.get("user_id")
    if not user_id:
        raise ValueError("Token missing user_id claim")
    
    return int(user_id)
```


**Authentication Router**:
```python
# apps/api/app/routers/auth.py

from fastapi import APIRouter, HTTPException, Depends, Response
from pydantic import BaseModel
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

router = APIRouter()
logger = logging.getLogger(__name__)

class AuthRequest(BaseModel):
    initData: str

class UserInfo(BaseModel):
    id: int
    telegram_id: int
    first_name: str
    last_name: str | None = None
    username: str | None = None

class AuthResponse(BaseModel):
    success: bool
    user: UserInfo

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
        # Source: FastAPI cookie documentation
        # Verified: HttpOnly prevents JavaScript access, Secure requires HTTPS
        # Cookie Policy:
        # - Domain: .yourdomain.com (shared between app.* and api.*)
        # - Path: / (available to all routes)
        # - SameSite: None (cross-domain) REQUIRES Secure: True
        # - max_age: 86400 seconds (24 hours) - preferred over expires
        response.set_cookie(
            key="session",
            value=access_token,
            httponly=True,  # Prevents JavaScript access
            secure=settings.COOKIE_SECURE,  # HTTPS only (MUST be True in production)
            samesite=settings.COOKIE_SAMESITE,  # "none" for cross-domain
            max_age=settings.COOKIE_MAX_AGE,  # 86400 seconds = 24 hours
            domain=settings.COOKIE_DOMAIN,  # ".yourdomain.com" for subdomain sharing
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
```

**Preferences Router**:
```python
# apps/api/app/routers/prefs.py

from fastapi import APIRouter, HTTPException, Depends, Cookie
from pydantic import BaseModel
import asyncpg
import logging

from app.database import get_db_pool
from app.auth import extract_user_id_from_cookie

router = APIRouter()
logger = logging.getLogger(__name__)

class PreferencesModel(BaseModel):
    theme_mode: str = "premium"
    reduced_motion: bool = False

@router.get("", response_model=PreferencesModel)
async def get_preferences(
    session: str = Cookie(None),
    pool: asyncpg.Pool = Depends(get_db_pool)
) -> PreferencesModel:
    """Get user preferences from database."""
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
    session: str = Cookie(None),
    pool: asyncpg.Pool = Depends(get_db_pool)
) -> PreferencesModel:
    """Update user preferences in database."""
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
```

**Health Check Router**:
```python
# apps/api/app/routers/health.py

from fastapi import APIRouter, Depends
import asyncpg
import logging

from app.database import get_db_pool

router = APIRouter()
logger = logging.getLogger(__name__)

@router.get("/health")
async def health_check(pool: asyncpg.Pool = Depends(get_db_pool)):
    """Health check endpoint - no authentication required."""
    try:
        async with pool.acquire() as conn:
            await conn.fetchval("SELECT 1")
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {"status": "unhealthy", "error": str(e)}
```


## Deployment Configuration (VDS Ubuntu 24.04)

### Nginx Configuration

**Frontend (app.yourdomain.com)**:
```nginx
# /etc/nginx/sites-available/tma-studio-app

server {
    listen 80;
    server_name app.yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app.yourdomain.com;
    
    # SSL certificates (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/app.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.yourdomain.com/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Root directory for static files
    root /var/www/tma-studio/dist;
    index index.html;
    
    # Serve static files
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

**Backend (api.yourdomain.com)**:
```nginx
# /etc/nginx/sites-available/tma-studio-api

server {
    listen 80;
    server_name api.yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;
    
    # SSL certificates (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Proxy to FastAPI
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### Systemd Services

**API Service**:
```ini
# /etc/systemd/system/tma-studio-api.service

[Unit]
Description=TMA Studio FastAPI Backend
After=network.target postgresql.service

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/tma-studio/apps/api
Environment="PATH=/opt/tma-studio/venv/bin"
EnvironmentFile=/opt/tma-studio/apps/api/.env
# --proxy-headers: Trust X-Forwarded-* headers from Nginx for correct scheme/host detection
# Required for: secure cookies (https scheme), CORS origin validation, redirect URLs
ExecStart=/opt/tma-studio/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000 --workers 4 --proxy-headers
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Bot Service**:
```ini
# /etc/systemd/system/tma-studio-bot.service

[Unit]
Description=TMA Studio Telegram Bot
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/tma-studio/apps/bot
Environment="PATH=/opt/tma-studio/venv/bin"
EnvironmentFile=/opt/tma-studio/apps/bot/.env
ExecStart=/opt/tma-studio/venv/bin/python bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Database Migration

```sql
-- apps/api/migrations/001_initial.sql

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255),
    username VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_telegram_id ON users(telegram_id);

-- User preferences table
CREATE TABLE IF NOT EXISTS user_preferences (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    theme_mode VARCHAR(20) DEFAULT 'premium' CHECK (theme_mode IN ('native', 'premium', 'mixed')),
    reduced_motion BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences(user_id);
```

**Apply Migration**:
```bash
# On VDS
psql $DATABASE_URL -f /opt/tma-studio/apps/api/migrations/001_initial.sql
```


## Secrets Management

### What is a Secret?

**Secrets** (NEVER in code/repo):
- `BOT_TOKEN` - Telegram bot token
- `JWT_SECRET` - JWT signing key
- `DATABASE_URL` - Database connection string with password
- Any API keys, passwords, private keys

**Not Secrets** (can be in code):
- `ALLOWED_ORIGINS` - Public domain names
- `JWT_ALGORITHM` - Algorithm name (HS256)
- `JWT_EXPIRATION_HOURS` - Token expiration time
- `COOKIE_SAMESITE` - Cookie settings

### Environment Variables (Production)

```env
# /opt/tma-studio/apps/api/.env

# Telegram
BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz

# Database (Supabase)
DATABASE_URL=postgresql://user:password@db.supabase.co:5432/postgres

# JWT
JWT_SECRET=your-random-secret-key-min-32-chars
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# InitData validation
# Default: 86400 (24 hours) for demo/development
# Production recommendation: 300-600 seconds (5-10 minutes) for tighter security
INIT_DATA_MAX_AGE_SECONDS=86400

# CORS - MUST be explicit list (not "*") when allow_credentials=True
ALLOWED_ORIGINS=["https://app.yourdomain.com"]

# Cookies
COOKIE_DOMAIN=.yourdomain.com
COOKIE_SECURE=true
COOKIE_SAMESITE=none
COOKIE_MAX_AGE=86400
```

```env
# /opt/tma-studio/apps/bot/.env

# Telegram
BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz

# Web App URL
WEB_APP_URL=https://app.yourdomain.com
```

```env
# /opt/tma-studio/apps/web/.env (build-time)

# API URL for production
PUBLIC_API_URL=https://api.yourdomain.com
```

### Security Checklist

- [ ] All secrets in environment variables, not code
- [ ] `.env` files in `.gitignore`
- [ ] `.env.example` files with placeholder values
- [ ] File permissions: `chmod 600 .env` (owner read/write only)
- [ ] JWT_SECRET is random, minimum 32 characters
- [ ] HTTPS enabled (Let's Encrypt)
- [ ] HttpOnly cookies enabled
- [ ] CORS configured with explicit origins
- [ ] Database connection uses SSL (Supabase default)
- [ ] Bot token never logged or exposed in errors

### Generating Secrets

```bash
# Generate JWT_SECRET (32 random bytes, base64 encoded)
openssl rand -base64 32

# Get BOT_TOKEN from @BotFather on Telegram
# Get DATABASE_URL from Supabase dashboard
```

## Tailwind CSS v4 Configuration

**Approach**: CSS-first (no tailwind.config.js)

**Source**: Tailwind CSS v4 documentation
**Verified**: v4 uses `@import "tailwindcss"` with CSS custom properties

```css
/* apps/web/src/styles/global.css */

@import "tailwindcss";

/* Premium theme (default) */
:root {
  /* Colors */
  --color-bg-primary: #0a0a0f;
  --color-bg-secondary: #13131a;
  --color-text-primary: #ffffff;
  --color-accent-primary: #6366f1;
  
  /* Gradients */
  --gradient-primary: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  
  /* Shadows */
  --shadow-md: 0 4px 16px rgba(0, 0, 0, 0.2);
  --shadow-glow: 0 0 32px rgba(99, 102, 241, 0.4);
  
  /* Radius */
  --radius-md: 16px;
  --radius-lg: 24px;
  
  /* Telegram theme params (populated by tg.theme.applyToCSS()) */
  --tg-bg-color: #0a0a0f;
  --tg-text-color: #ffffff;
}

/* Native theme: use Telegram colors */
[data-theme="native"] {
  --color-bg-primary: var(--tg-bg-color, #ffffff);
  --color-text-primary: var(--tg-text-color, #000000);
  --color-accent-primary: var(--tg-button-color, #3390ec);
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

**Astro Config**:
```javascript
// apps/web/astro.config.mjs

import { defineConfig } from 'astro/config';
import svelte from '@astrojs/svelte';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  integrations: [svelte()],
  vite: {
    plugins: [tailwindcss()],
  },
});
```

## Performance Guidelines (MVP)

**MVP Targets** (realistic, not strict SLA):
- No console errors in Telegram WebView
- Feels fast (subjective, but no obvious lag)
- Bundle size < 150KB initial JS
- Islands architecture (only interactive components load JS)
- Lazy loading for below-fold content

**Animation Rules**:
- Default: Only `transform` and `opacity`
- Avoid: `width`, `height`, `top`, `left`, `margin`, `padding`
- Duration: 150-250ms for micro-interactions
- Respect `prefers-reduced-motion`

**Phase 2 Targets** (measured):
- FCP < 2s on 3G
- TTI < 4s on 3G
- LCP < 2.5s
- CLS < 0.1
- Lighthouse score > 90

## Risks & Non-Goals

### Risks

1. **HTTPS Requirement**: Telegram Mini Apps require HTTPS. Mitigation: Let's Encrypt on VDS.
2. **Cookie Cross-Domain**: SameSite=None requires HTTPS. Mitigation: Proper SSL setup.
3. **CORS Configuration**: Must be exact origins for credentials. Mitigation: Explicit ALLOWED_ORIGINS.
4. **Database Connection**: Supabase connection pooling limits. Mitigation: asyncpg pool with max_size=20.
5. **Bot Token Security**: Must never be exposed. Mitigation: Environment variables only, never in code/logs.

### Non-Goals (MVP)

1. **Unit Tests**: Deferred to Phase 2
2. **Property-Based Tests**: Deferred to Phase 2/3
3. **Multi-Language Support**: English only in MVP
4. **Analytics**: No tracking in MVP
5. **Error Monitoring**: No Sentry in MVP
6. **Image Optimization**: Simple PNGs/SVGs in MVP
7. **Advanced Animations**: No Motion.dev in MVP
8. **Performance SLA**: No strict 3G metrics in MVP


## Design Document Changelog

### Changes from Previous Version

**1. MVP Scope Redefined**
- **Changed**: MVP now includes full backend (FastAPI + Postgres)
- **Removed**: "NO backend in MVP" section
- **Added**: Production deployment on VDS Ubuntu 24.04
- **Rationale**: Client requires production-ready MVP with real auth

**2. Authentication Method**
- **Changed**: HttpOnly cookies instead of JWT in localStorage
- **Added**: Complete cookie-based auth implementation
- **Added**: CORS configuration with `allow_credentials=True`
- **Rationale**: More secure than localStorage, prevents XSS attacks

**3. API Contracts**
- **Added**: Complete API contracts with request/response examples
- **Added**: Error responses for all endpoints
- **Removed**: Mock API implementation
- **Rationale**: Agent needs exact contracts for implementation

**4. Deployment Architecture**
- **Added**: VDS deployment with Nginx reverse proxy
- **Added**: Systemd service configurations
- **Added**: Let's Encrypt SSL setup
- **Added**: Database migration SQL
- **Rationale**: Production-ready deployment required in MVP

**5. Secrets Management**
- **Added**: Complete secrets checklist
- **Added**: What is/isn't a secret
- **Added**: Security checklist
- **Rationale**: Prevent accidental secret exposure

**6. CORS Configuration**
- **Added**: Explicit CORS setup for cookie-based auth
- **Added**: Source verification from FastAPI docs
- **Rationale**: Cookies require specific CORS settings

**7. Theme Management**
- **Changed**: Theme syncs to database, not just localStorage
- **Added**: Async theme.load() from backend
- **Rationale**: Preferences must persist across devices

**8. Performance Targets**
- **Changed**: MVP has realistic targets (no strict SLA)
- **Moved**: Strict performance metrics to Phase 2
- **Rationale**: MVP focuses on functionality, Phase 2 on optimization

**9. Phase 2 Scope**
- **Moved**: Additional pages (Haptics, Viewport, Motion, Forms, Cards) to Phase 2
- **Moved**: Unit tests and property-based tests to Phase 2/3
- **Rationale**: Focus MVP on core functionality + deployment

**10. Documentation**
- **Added**: Complete implementation code for all components
- **Added**: Nginx configurations
- **Added**: Systemd service files
- **Rationale**: Agent can generate directly from design doc

