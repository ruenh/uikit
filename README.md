# TMA Studio UI Kit

> Production-ready Telegram Mini App UI Kit with full-stack authentication, theme management, and premium design components.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Astro](https://img.shields.io/badge/Astro-4.x-FF5D01?logo=astro)](https://astro.build/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-v4-38B2AC?logo=tailwind-css)](https://tailwindcss.com/)

A comprehensive showcase and starter kit for building premium Telegram Mini Apps with modern web technologies. Features full-stack authentication, database-backed preferences, and production-ready deployment configurations.

## ✨ Features

- 🔐 **Full-stack Authentication** - HMAC-SHA256 initData validation with HttpOnly cookies
- 🎨 **Advanced Theme System** - Native, Premium, and Mixed modes with database persistence
- 🗄️ **PostgreSQL Integration** - User preferences and session management
- 🚀 **Production Ready** - Complete deployment configs for VDS with Nginx + HTTPS
- 📱 **6 Demo Pages** - Comprehensive showcase of Telegram WebApp API features
- ⚡ **View Transitions** - Smooth page navigation with shared element morphing
- 🎯 **TypeScript** - Full type safety across frontend and backend
- 🤖 **Bot Integration** - aiogram 3.x bot for launching Mini Apps

## 🏗️ Tech Stack

### Frontend
- **[Astro](https://astro.build/)** - Static site generator with islands architecture
- **[Svelte](https://svelte.dev/)** - Reactive UI components
- **[Tailwind CSS v4](https://tailwindcss.com/)** - Utility-first CSS framework

### Backend
- **[FastAPI](https://fastapi.tiangolo.com/)** - Modern Python web framework
- **[PostgreSQL](https://www.postgresql.org/)** - Relational database (Supabase recommended)
- **[aiogram 3.x](https://docs.aiogram.dev/)** - Telegram Bot API framework

## 🚀 Quick Start

### Prerequisites

- Node.js 20+
- Python 3.12+
- PostgreSQL database
- Telegram Bot Token (from [@BotFather](https://t.me/BotFather))

### Installation

```bash
# Clone repository
git clone https://github.com/ruenh/uikit.git
cd uikit

# Install web dependencies
cd apps/web
npm install

# Install API dependencies
cd ../api
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Install bot dependencies
cd ../bot
pip install -r requirements.txt
```

### Configuration

Create `.env` files from examples:

```bash
# Web app
cp apps/web/.env.example apps/web/.env

# API
cp apps/api/.env.example apps/api/.env

# Bot
cp apps/bot/.env.example apps/bot/.env
```

Edit each `.env` file with your configuration. See [Environment Variables](#-environment-variables) for details.

### Database Setup

```bash
# Apply migrations
psql $DATABASE_URL -f apps/api/migrations/001_initial.sql
```

### Run Development Servers

```bash
# Terminal 1 - Web App
cd apps/web
npm run dev

# Terminal 2 - API
cd apps/api
source venv/bin/activate
uvicorn app.main:app --reload

# Terminal 3 - Bot
cd apps/bot
source venv/bin/activate
python bot.py
```

## 📁 Project Structure

```
uikit/
├── apps/
│   ├── web/              # Astro + Svelte frontend
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── islands/    # Interactive Svelte components
│   │   │   │   └── ui/         # Static Astro components
│   │   │   ├── lib/            # tg.ts, api.ts, theme.ts
│   │   │   ├── pages/          # 6 demo pages
│   │   │   └── styles/
│   │   └── package.json
│   │
│   ├── api/              # FastAPI backend
│   │   ├── app/
│   │   │   ├── routers/        # auth, prefs, health
│   │   │   ├── auth.py         # JWT + initData validation
│   │   │   └── main.py
│   │   ├── migrations/
│   │   └── requirements.txt
│   │
│   └── bot/              # aiogram Telegram bot
│       ├── bot.py
│       └── requirements.txt
│
├── deploy/               # Production deployment configs
│   ├── nginx/            # Nginx configurations
│   ├── systemd/          # systemd service files
│   └── scripts/          # Deployment scripts
│
└── docs/                 # Documentation
    ├── deployment.md     # Full deployment guide
    └── telegram-standards.md
```

## 🔐 Environment Variables

### API Configuration

| Variable | Required | Description |
|----------|----------|-------------|
| `BOT_TOKEN` | Yes | Telegram bot token from @BotFather |
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `JWT_SECRET` | Yes | Secret key for JWT signing (min 32 chars) |
| `ALLOWED_ORIGINS` | Yes | CORS origins (JSON array) |
| `COOKIE_DOMAIN` | Yes | Cookie domain (`.yourdomain.com` or `localhost`) |
| `COOKIE_SECURE` | No | Require HTTPS for cookies (default: `true`) |
| `COOKIE_SAMESITE` | No | SameSite policy (default: `none`) |

### Bot Configuration

| Variable | Required | Description |
|----------|----------|-------------|
| `BOT_TOKEN` | Yes | Telegram bot token (same as API) |
| `WEB_APP_URL` | Yes | Frontend URL for Mini App |

### Frontend Configuration

| Variable | Required | Description |
|----------|----------|-------------|
| `PUBLIC_API_URL` | Yes | Backend API URL |

## 🌐 Production Deployment

Complete deployment guide available in [docs/deployment.md](docs/deployment.md).

### Quick Deployment Steps

1. Prepare VDS with Ubuntu 24.04
2. Configure DNS records
3. Install dependencies (Nginx, Python, Node.js, Certbot)
4. Deploy code to `/opt/tma-studio`
5. Configure environment variables
6. Apply database migrations
7. Set up Nginx reverse proxy
8. Obtain SSL certificates
9. Configure systemd services
10. Verify deployment

### Production Environment Example

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

## 📚 Documentation

- **[Deployment Guide](docs/deployment.md)** - Complete VDS deployment instructions
- **[Telegram Standards](docs/telegram-standards.md)** - Mini Apps best practices
- **[API Documentation](.kiro/specs/tma-studio/design.md)** - API endpoints and contracts

## 🎯 Demo Pages

1. **Home** - Navigation hub with premium design
2. **Buttons** - MainButton and BackButton demonstrations
3. **Popups** - showPopup, showAlert, showConfirm examples
4. **Theme** - Theme switcher with live preview
5. **Navigation** - View Transitions showcase
6. **Integrations** - Authentication and preferences sync

## 🔒 Security Features

- ✅ Server-side initData validation (HMAC-SHA256)
- ✅ HttpOnly cookies for session management
- ✅ CORS protection with explicit origins
- ✅ JWT-based authentication
- ✅ PostgreSQL with SSL support
- ✅ Environment-based configuration
- ✅ Production-ready security headers

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with modern web technologies:

- [Astro](https://astro.build/) - Static site generator
- [Svelte](https://svelte.dev/) - Reactive UI framework
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS
- [FastAPI](https://fastapi.tiangolo.com/) - Python web framework
- [aiogram](https://docs.aiogram.dev/) - Telegram Bot framework
- [Supabase](https://supabase.com/) - PostgreSQL platform

## 📞 Support

For issues and questions:

1. Check [documentation](docs/)
2. Review [Telegram Mini Apps docs](https://core.telegram.org/bots/webapps)
3. Open an issue in this repository

---

**Built for the Telegram Mini Apps ecosystem** 🚀
