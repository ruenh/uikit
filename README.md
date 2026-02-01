# TMA Studio

A premium Telegram Mini App showcase demonstrating best practices for building Mini Apps with modern web technologies. This application serves as a UX/UI kit and integrations showcase, featuring premium design, Telegram-native integration, and engineering excellence.

## 🏗️ Architecture

TMA Studio is a full-stack monorepo consisting of three main components:

1. **Web Application** (`apps/web/`) - Astro + Svelte + Tailwind CSS v4 Mini App with premium design
2. **API Backend** (`apps/api/`) - FastAPI service for initData validation and preferences storage
3. **Bot** (`apps/bot/`) - Python aiogram 3.x bot for launching the Mini App

### System Architecture

```
Telegram User
    │
    ├─→ Bot (/start command)
    │       │
    │       └─→ Opens Mini App with initData
    │
    └─→ Mini App (app.yourdomain.com)
            │
            ├─→ API (api.yourdomain.com)
            │       │
            │       ├─→ Validates initData (HMAC-SHA256)
            │       ├─→ Sets HttpOnly session cookie
            │       └─→ Stores preferences in PostgreSQL
            │
            └─→ Telegram WebApp API
                    ├─→ Theme integration
                    ├─→ MainButton/BackButton
                    └─→ Popups and haptics
```

## 📁 Project Structure

```
tma-studio/
├── apps/
│   ├── web/          # Astro + Svelte frontend
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── islands/    # Interactive Svelte components
│   │   │   │   └── ui/         # Static Astro components
│   │   │   ├── layouts/
│   │   │   ├── pages/          # 6 demo pages
│   │   │   ├── lib/            # tg.ts, api.ts, theme.ts
│   │   │   └── styles/
│   │   └── astro.config.mjs
│   │
│   ├── api/          # FastAPI backend
│   │   ├── app/
│   │   │   ├── main.py         # FastAPI app + CORS
│   │   │   ├── config.py       # Settings from env
│   │   │   ├── auth.py         # JWT + initData validation
│   │   │   └── routers/        # auth, prefs, health
│   │   ├── migrations/
│   │   └── requirements.txt
│   │
│   └── bot/          # aiogram Telegram bot
│       ├── bot.py
│       └── requirements.txt
│
├── deploy/           # Deployment configurations
│   ├── nginx/        # Nginx configs for app + api
│   └── systemd/      # systemd service files
│
├── docs/             # Documentation
│   ├── deployment.md         # Full VDS deployment guide
│   ├── architecture.md
│   └── telegram-standards.md
│
└── .kiro/            # Kiro AI specifications
```

## 🚀 Quick Start (Local Development)

### Prerequisites

- **Node.js** 20+ (for web app)
- **Python** 3.12+ (for API and bot)
- **PostgreSQL** database (Supabase recommended)
- **Telegram Bot Token** (from [@BotFather](https://t.me/BotFather))

### 1. Clone and Install

```bash
# Clone the repository
git clone <repository-url>
cd tma-studio

# Install web dependencies
cd apps/web
npm install

# Install API dependencies
cd ../api
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Install bot dependencies
cd ../bot
pip install -r requirements.txt
```

### 2. Configure Environment Variables

#### Web App (`apps/web/.env`)

```env
# API URL for local development
PUBLIC_API_URL=http://localhost:8000
```

Create from example:

```bash
cp apps/web/.env.example apps/web/.env
# Edit .env and set PUBLIC_API_URL
```

#### API (`apps/api/.env`)

```env
# Telegram Bot Token (get from @BotFather)
BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz

# Database Connection (Supabase or local PostgreSQL)
DATABASE_URL=postgresql://user:password@localhost:5432/tma_studio

# JWT Configuration
JWT_SECRET=your-random-secret-key-min-32-chars-here
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# InitData Validation
# For local development: 86400 (24 hours)
# For production: 300-600 (5-10 minutes)
INIT_DATA_MAX_AGE_SECONDS=86400

# CORS Configuration
# CRITICAL: Must be explicit list (not "*") when using credentials
ALLOWED_ORIGINS=["http://localhost:4321"]

# Cookie Settings (for local development)
COOKIE_DOMAIN=localhost
COOKIE_SECURE=false
COOKIE_SAMESITE=lax
COOKIE_MAX_AGE=86400
```

Create from example:

```bash
cp apps/api/.env.example apps/api/.env
# Edit .env and set all required variables
```

**Generate JWT Secret:**

```bash
openssl rand -base64 32
```

#### Bot (`apps/bot/.env`)

```env
# Telegram Bot Token (same as API)
BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz

# Web App URL (local development)
WEB_APP_URL=http://localhost:4321
```

Create from example:

```bash
cp apps/bot/.env.example apps/bot/.env
# Edit .env and set BOT_TOKEN and WEB_APP_URL
```

### 3. Set Up Database

```bash
# Apply database migrations
cd apps/api
psql $DATABASE_URL -f migrations/001_initial.sql

# Verify tables created
psql $DATABASE_URL -c "\dt"
# Should show: users, user_preferences
```

### 4. Run Services

Open three terminal windows:

**Terminal 1 - Web App:**

```bash
cd apps/web
npm run dev
# Runs on http://localhost:4321
```

**Terminal 2 - API:**

```bash
cd apps/api
source venv/bin/activate  # On Windows: venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
# Runs on http://localhost:8000
```

**Terminal 3 - Bot:**

```bash
cd apps/bot
source venv/bin/activate  # On Windows: venv\Scripts\activate
python bot.py
# Bot starts polling
```

### 5. Test the Application

1. Open your Telegram bot
2. Send `/start` command
3. Click "Open TMA Studio" button
4. Mini App should load in Telegram

**Note**: For local development, Telegram Mini Apps require HTTPS. You can use:

- **ngrok** or **localtunnel** to expose localhost
- **Telegram Desktop** (supports http://localhost in dev mode)
- Deploy to a test VDS with HTTPS

## 🔐 Environment Variables Reference

### API Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `BOT_TOKEN` | **Yes** | - | Telegram bot token from @BotFather |
| `DATABASE_URL` | **Yes** | - | PostgreSQL connection string |
| `JWT_SECRET` | **Yes** | - | Secret key for JWT signing (min 32 chars) |
| `JWT_ALGORITHM` | No | `HS256` | JWT algorithm |
| `JWT_EXPIRATION_HOURS` | No | `24` | Token expiration in hours |
| `INIT_DATA_MAX_AGE_SECONDS` | No | `86400` | Max age for initData validation |
| `ALLOWED_ORIGINS` | **Yes** | - | List of allowed CORS origins (JSON array) |
| `COOKIE_DOMAIN` | **Yes** | - | Cookie domain (`.yourdomain.com` for production, `localhost` for dev) |
| `COOKIE_SECURE` | No | `true` | Require HTTPS for cookies (`false` for local dev) |
| `COOKIE_SAMESITE` | No | `none` | SameSite policy (`lax` for local dev, `none` for production) |
| `COOKIE_MAX_AGE` | No | `86400` | Cookie max age in seconds |

### Bot Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `BOT_TOKEN` | **Yes** | Telegram bot token (same as API) |
| `WEB_APP_URL` | **Yes** | Frontend URL for Mini App |

### Frontend Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `PUBLIC_API_URL` | **Yes** | Backend API URL |

### Environment Variable Examples

**Local Development:**

```env
# API
ALLOWED_ORIGINS=["http://localhost:4321"]
COOKIE_DOMAIN=localhost
COOKIE_SECURE=false
COOKIE_SAMESITE=lax

# Bot
WEB_APP_URL=http://localhost:4321

# Frontend
PUBLIC_API_URL=http://localhost:8000
```

**Production:**

```env
# API
ALLOWED_ORIGINS=["https://app.yourdomain.com"]
COOKIE_DOMAIN=.yourdomain.com
COOKIE_SECURE=true
COOKIE_SAMESITE=none

# Bot
WEB_APP_URL=https://app.yourdomain.com

# Frontend
PUBLIC_API_URL=https://api.yourdomain.com
```

## 🌐 Production Deployment

TMA Studio is designed for production deployment on a VDS (Virtual Dedicated Server) with Ubuntu 24.04, Nginx, and Let's Encrypt SSL certificates.

### Deployment Architecture

```
VDS Ubuntu 24.04
├── Nginx (port 80/443)
│   ├── app.yourdomain.com → /var/www/tma-studio/dist (static files)
│   └── api.yourdomain.com → proxy_pass http://127.0.0.1:8000
├── FastAPI (port 8000)
│   └── systemd service: tma-studio-api.service
├── Bot (aiogram)
│   └── systemd service: tma-studio-bot.service
└── PostgreSQL (Supabase or self-hosted)
```

### Quick Deployment Steps

1. **Prepare VDS**: Ubuntu 24.04 with root access
2. **Configure DNS**: Point `app.yourdomain.com` and `api.yourdomain.com` to VDS IP
3. **Install dependencies**: Nginx, Python 3.12, Node.js 20, Certbot
4. **Deploy code**: Clone repo to `/opt/tma-studio`
5. **Configure environment**: Set up `.env` files with production values
6. **Apply migrations**: Run database migrations
7. **Configure Nginx**: Set up reverse proxy and static file serving
8. **Configure SSL**: Obtain Let's Encrypt certificates
9. **Configure systemd**: Set up API and bot services
10. **Verify deployment**: Test health check and end-to-end flow

### Detailed Deployment Guide

For complete step-by-step deployment instructions, see **[docs/deployment.md](docs/deployment.md)**.

The deployment guide includes:

- Initial VDS setup and package installation
- Application code deployment
- Environment variable configuration
- Database migration
- Nginx configuration (frontend + backend)
- SSL certificate setup with Let's Encrypt
- systemd service configuration
- Troubleshooting common issues
- Maintenance and monitoring procedures

### Production Environment Variables

**Critical Production Settings:**

```env
# API (.env)
ALLOWED_ORIGINS=["https://app.yourdomain.com"]
COOKIE_DOMAIN=.yourdomain.com
COOKIE_SECURE=true
COOKIE_SAMESITE=none
INIT_DATA_MAX_AGE_SECONDS=600  # 10 minutes for tighter security

# Bot (.env)
WEB_APP_URL=https://app.yourdomain.com

# Frontend (.env)
PUBLIC_API_URL=https://api.yourdomain.com
```

### Deployment Checklist

Before going live, verify:

- [ ] DNS records point to VDS IP
- [ ] HTTPS enabled with valid SSL certificates
- [ ] All `.env` files configured with production values
- [ ] Database migrations applied
- [ ] systemd services running and enabled
- [ ] Health check endpoint responds: `curl https://api.yourdomain.com/api/health`
- [ ] Bot responds to `/start` command
- [ ] Mini App loads in Telegram
- [ ] Authentication works (initData validation)
- [ ] Preferences persist across page reload
- [ ] No console errors in Telegram WebView

## 🧪 Smoke Test Procedure

After deployment (local or production), run this smoke test to verify all components work correctly:

### 1. Health Check

```bash
# Test API health endpoint
curl https://api.yourdomain.com/api/health

# Expected response:
# {"status":"healthy","database":"connected"}
```

### 2. Bot Test

1. Open Telegram and find your bot
2. Send `/start` command
3. **Expected**: Bot responds with welcome message and "Open TMA Studio" button

### 3. Mini App Launch

1. Click "Open TMA Studio" button
2. **Expected**: Mini App loads inside Telegram (no blank screen)
3. **Expected**: Home page displays with navigation tiles
4. **Expected**: No console errors in browser DevTools (if testing in Telegram Desktop)

### 4. Authentication Test

1. Navigate to **Integrations** page
2. **Expected**: User info displayed (first name, Telegram ID)
3. **Expected**: "Authenticated" status shown
4. **Expected**: No 401 errors in Network tab

### 5. Preferences Persistence Test

1. Navigate to **Theme** page
2. Change theme to "Native"
3. **Expected**: Theme changes immediately
4. Reload the page (pull down to refresh in mobile Telegram)
5. **Expected**: Theme remains "Native" (loaded from database)
6. Change theme to "Premium"
7. **Expected**: Theme changes and persists after reload

### 6. Navigation Test

1. Navigate between pages: Home → Buttons → Popups → Theme → Navigation
2. **Expected**: Smooth View Transitions between pages
3. **Expected**: No page load errors
4. **Expected**: Back button works correctly

### 7. Telegram Integration Test

1. Navigate to **Buttons** page
2. Click "Show Main Button"
3. **Expected**: Main button appears at bottom of Telegram
4. Click "Show Back Button"
5. **Expected**: Back button appears in header
6. Navigate to **Popups** page
7. Click "Show Alert"
8. **Expected**: Telegram alert popup appears

### 8. End-to-End Flow

Complete flow from start to finish:

```
1. Bot /start → 2. Open Mini App → 3. Home page loads
    ↓
4. Navigate to Integrations → 5. Auth succeeds → 6. User info shown
    ↓
7. Change theme → 8. Reload page → 9. Theme persisted
    ↓
10. Navigate to Buttons → 11. Test MainButton → 12. Works correctly
```

### Smoke Test Checklist

- [ ] Health check returns "healthy"
- [ ] Bot responds to `/start`
- [ ] Mini App loads in Telegram
- [ ] No console errors
- [ ] Authentication works (user info displayed)
- [ ] Theme persists after reload
- [ ] Navigation works (View Transitions)
- [ ] MainButton/BackButton work
- [ ] Popups work (alert, confirm)
- [ ] No 401/403/500 errors in Network tab

### Troubleshooting Failed Smoke Tests

**If health check fails:**

- Check API service: `systemctl status tma-studio-api.service`
- Check database connection: `psql $DATABASE_URL -c "SELECT 1"`
- Check logs: `journalctl -u tma-studio-api.service -n 50`

**If authentication fails:**

- Verify `BOT_TOKEN` matches in API and bot `.env` files
- Check CORS settings: `ALLOWED_ORIGINS` must match frontend domain
- Check cookie settings: `COOKIE_SECURE=true` requires HTTPS
- Check logs for "Invalid authentication data"

**If preferences don't persist:**

- Verify database tables exist: `psql $DATABASE_URL -c "\dt"`
- Check API logs for database errors
- Verify `credentials: 'include'` in frontend API calls

**If Mini App doesn't load:**

- Verify `WEB_APP_URL` in bot `.env` matches frontend domain
- Check Nginx configuration for frontend
- Verify SSL certificate is valid
- Check browser console for errors

## 🛠️ Development Commands

### Web App Commands

```bash
cd apps/web

# Development
npm run dev          # Start dev server (http://localhost:4321)
npm run build        # Build for production
npm run preview      # Preview production build

# Linting and formatting
npm run lint         # Lint code (if configured)
npm run format       # Format code (if configured)
```

### API Commands

```bash
cd apps/api
source venv/bin/activate  # Activate virtual environment

# Development
uvicorn app.main:app --reload              # Development with hot reload
uvicorn app.main:app --reload --log-level debug  # With debug logging

# Production
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

# Testing (Phase 2)
pytest                                      # Run tests
pytest --cov=app                           # Run tests with coverage
```

### Bot Commands

```bash
cd apps/bot
source venv/bin/activate  # Activate virtual environment

# Run bot
python bot.py        # Start bot in polling mode

# Testing
python -m pytest     # Run tests (Phase 2)
```

### Database Commands

```bash
# Apply migrations
psql $DATABASE_URL -f apps/api/migrations/001_initial.sql

# Connect to database
psql $DATABASE_URL

# Backup database
pg_dump $DATABASE_URL > backup.sql

# Restore database
psql $DATABASE_URL < backup.sql

# List tables
psql $DATABASE_URL -c "\dt"

# Query users
psql $DATABASE_URL -c "SELECT * FROM users LIMIT 10;"
```

## 🔒 Security Best Practices

### Secrets Management

- **Never commit `.env` files** - they contain secrets
- **Use `.env.example`** - provide template with placeholder values
- **Generate strong JWT_SECRET**: `openssl rand -base64 32`
- **Rotate secrets regularly** - especially after team member changes
- **Use environment variables** - never hardcode secrets in code

### Production Security

- **HTTPS required** - Telegram Mini Apps require HTTPS
- **HttpOnly cookies** - prevents XSS attacks on session tokens
- **CORS configuration** - explicit origins only (not "*")
- **initData validation** - always validate server-side with HMAC-SHA256
- **Short initData TTL** - use 5-10 minutes in production (`INIT_DATA_MAX_AGE_SECONDS=600`)
- **Database SSL** - use SSL for database connections (Supabase default)
- **File permissions** - `.env` files should be 600 (owner read/write only)
- **Service user** - run services as `www-data`, not root

### Security Checklist

- [ ] All `.env` files in `.gitignore`
- [ ] JWT_SECRET is strong (min 32 random characters)
- [ ] HTTPS enabled in production
- [ ] `COOKIE_SECURE=true` in production
- [ ] `ALLOWED_ORIGINS` contains only your domain (not "*")
- [ ] initData validation enabled with short TTL
- [ ] Database connection uses SSL
- [ ] Bot token never logged or exposed
- [ ] File permissions restrictive (600 for .env)
- [ ] Services run as non-root user

## 📚 Documentation

### Project Documentation

- **[Deployment Guide](docs/deployment.md)** - Complete VDS deployment instructions
- **[Architecture](docs/architecture.md)** - System architecture and component relationships
- **[Telegram Standards](docs/telegram-standards.md)** - Mini Apps best practices checklist
- **[API Contracts](.kiro/specs/tma-studio/design.md)** - API endpoints and data models

### External Resources

- [Telegram Mini Apps Documentation](https://core.telegram.org/bots/webapps)
- [Telegram Bot API](https://core.telegram.org/bots/api)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Astro Documentation](https://docs.astro.build/)
- [Svelte Documentation](https://svelte.dev/docs)
- [Tailwind CSS v4](https://tailwindcss.com/)

## 🎯 Features

### MVP Features (Phase 1) ✅

- ✅ **Full-stack authentication** - HMAC-SHA256 initData validation with HttpOnly cookies
- ✅ **Database-backed preferences** - PostgreSQL storage with Supabase
- ✅ **Theme system** - Native, Premium, and Mixed modes with persistence
- ✅ **6 demo pages** - Home, Buttons, Popups, Theme, Navigation, Integrations
- ✅ **Telegram WebApp API integration** - MainButton, BackButton, Popups, Theme
- ✅ **Production deployment** - VDS + Nginx + HTTPS with Let's Encrypt
- ✅ **View Transitions** - Smooth page navigation with shared element morphing
- ✅ **Responsive design** - Adapts to Telegram viewport changes
- ✅ **Security-first** - Server-side validation, HttpOnly cookies, CORS protection

### Demo Pages

1. **Home** - Navigation hub with premium design
2. **Buttons** - MainButton and BackButton demonstrations
3. **Popups** - showPopup, showAlert, showConfirm examples
4. **Theme** - Theme switcher with live CSS variable display
5. **Navigation** - View Transitions showcase
6. **Integrations** - Authentication and preferences sync demo

## 📋 Requirements

This project implements requirements from `.kiro/specs/tma-studio/requirements.md`:

- **Requirement 3**: Authentication and Security (HMAC-SHA256 validation)
- **Requirement 6**: Theme System (Native, Premium, Mixed modes)
- **Requirement 10**: Backend API Architecture (FastAPI + Postgres)
- **Requirement 11**: Bot Implementation (aiogram 3.x)
- **Requirement 12**: Monorepo Structure
- **Requirement 13**: Documentation (deployment, architecture, standards)
- **Requirement 15**: Production Deployment (VDS + Nginx + HTTPS)

## 🔮 Roadmap

### Phase 2 (Showcase Expansion)

- Additional demo pages (Haptics, Viewport Lab, Motion, Forms, Cards)
- Motion.dev animations showcase
- Advanced Telegram integrations (deep links, QR codes)
- Visual polish (noise textures, advanced glow effects)
- Image optimization (WebP/AVIF with srcset)

### Phase 3 (Quality & Testing)

- Unit tests (frontend + backend)
- Property-based tests (optional)
- Performance optimization (Lighthouse > 90)
- Web Vitals monitoring (FCP < 2s, TTI < 4s on 3G)
- Error monitoring (Sentry)
- Analytics integration

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Follow the existing code style and conventions
4. Test your changes thoroughly (run smoke test)
5. Update documentation if needed
6. Submit a pull request with clear description

### Development Guidelines

- Follow security best practices (never commit secrets)
- Write clear commit messages
- Update tests when adding features (Phase 2+)
- Document environment variables in `.env.example`
- Test in Telegram before submitting PR

## 📞 Support

### Getting Help

For issues and questions:

1. **Check documentation first**:
   - [Deployment Guide](docs/deployment.md) - deployment issues
   - [Telegram Standards](docs/telegram-standards.md) - Mini Apps best practices
   - [Architecture](docs/architecture.md) - system design questions

2. **Common issues**:
   - CORS errors → Check `ALLOWED_ORIGINS` in API `.env`
   - Authentication fails → Verify `BOT_TOKEN` matches in API and bot
   - Cookies not set → Ensure `COOKIE_SECURE=true` only with HTTPS
   - Database errors → Check `DATABASE_URL` and run migrations

3. **External resources**:
   - [Telegram Mini Apps Documentation](https://core.telegram.org/bots/webapps)
   - [Telegram Bot API](https://core.telegram.org/bots/api)
   - [FastAPI Documentation](https://fastapi.tiangolo.com/)

4. **Still stuck?** Open an issue in the repository with:
   - Clear description of the problem
   - Steps to reproduce
   - Environment (local dev or production)
   - Relevant logs or error messages

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

Built with modern web technologies:

- **[Astro](https://astro.build/)** - Static site generator with islands architecture
- **[Svelte](https://svelte.dev/)** - Reactive UI components
- **[Tailwind CSS v4](https://tailwindcss.com/)** - Utility-first CSS framework
- **[FastAPI](https://fastapi.tiangolo.com/)** - Modern Python web framework
- **[aiogram](https://docs.aiogram.dev/)** - Telegram Bot API framework
- **[Supabase](https://supabase.com/)** - PostgreSQL database platform

Special thanks to the Telegram team for the Mini Apps platform.

---

**Built with ❤️ for the Telegram Mini Apps ecosystem**

For questions about this showcase or custom Mini App development, please reach out through the repository.
