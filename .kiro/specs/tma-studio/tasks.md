# Implementation Plan: TMA Studio

## Overview

This implementation plan is structured in 3 phases with clear deliverables and Definition of Done for each phase.

**Phase 1 (MVP)**: Full-stack application with backend, deployable to production VDS
**Phase 2**: Showcase expansion with additional pages and features
**Phase 3**: Quality polish with tests and optimization

## PHASE 1: MVP (Production Ready)

### Definition of Done (Phase 1)
- [ ] Bot opens Mini App in Telegram client
- [ ] API validates initData and sets HttpOnly session cookie
- [ ] Preferences save to database and load on page reload
- [ ] Theme persists across sessions (from database)
- [ ] 6 pages render correctly (Home, Buttons, Popups, Theme, Navigation, Integrations)
- [ ] No console errors in Telegram WebView
- [ ] Deployed on VDS with HTTPS (Let's Encrypt)
- [ ] Health check endpoint responds
- [ ] Smoke test passes: bot → auth → prefs save → reload → prefs restored

### Tasks (Phase 1)

- [x] 1. Repository setup and monorepo structure
  - Create directory structure: apps/web, apps/api, apps/bot, deploy/, docs/
  - Initialize .gitignore with .env, node_modules, __pycache__, dist/
  - Create .env.example files for web, api, bot with documented variables
  - Create README.md with project overview and setup instructions
  - _Requirements: 12.1, 12.5_

- [ ] 2. Web app foundation (Astro + Svelte + Tailwind v4)
  - [x] 2.1 Initialize Astro project
    - Run `npm create astro@latest` in apps/web
    - Install dependencies: @astrojs/svelte, svelte, @tailwindcss/vite, tailwindcss
    - Configure astro.config.mjs with Svelte integration and Tailwind vite plugin
    - _Requirements: 14.1_
  
  - [x] 2.2 Configure Tailwind CSS v4 (CSS-first)
    - Create src/styles/global.css with `@import "tailwindcss"`
    - Define CSS custom properties for premium theme (colors, gradients, shadows, radius)
    - Define [data-theme="native"] and [data-theme="mixed"] selectors
    - Add @media (prefers-reduced-motion) rules
    - _Requirements: 1.1, 1.4, 1.8, 6.2, 6.3, 6.4_
  
  - [x] 2.3 Set up Astro View Transitions
    - Create src/layouts/Layout.astro with ViewTransitions component
    - Add <script src="https://telegram.org/js/telegram-web-app.js"></script>
    - Initialize Telegram WebApp (ready, expand, theme)
    - Add meta tags for viewport and theme-color
    - _Requirements: 2.1, 2.10, 4.1_

- [ ] 3. Core library modules
  - [x] 3.1 Create Telegram adapter (tg.ts)
    - Implement isAvailable() check
    - Implement ready(), expand() with availability checks
    - Implement mainButton methods (show, hide, setParams)
    - Implement backButton methods (show, hide)
    - Implement popup methods (show, alert, confirm) with browser fallbacks
    - Implement theme methods (getParams, applyToCSS, onThemeChanged)
    - Implement viewport methods (getHeight, onViewportChanged)
    - Implement initData methods (get, getUnsafe)
    - Add console warnings for unavailable API
    - _Requirements: 2.1, 2.2, 2.6, 2.7, 2.8_
  
  - [x] 3.2 Create API client (api.ts)
    - Define AuthResponse and PreferencesResponse interfaces
    - Implement api.auth.validate() with credentials: 'include'
    - Implement api.preferences.get() with credentials: 'include'
    - Implement api.preferences.update() with credentials: 'include'
    - Implement api.health.check()
    - Use PUBLIC_API_URL from environment
    - _Requirements: 3.2, 10.1, 10.2_
  
  - [x] 3.3 Create theme management (theme.ts)
    - Implement theme.set() with database sync
    - Implement theme.load() from API
    - Implement theme.init() for page load
    - Handle API errors gracefully (fallback to default)
    - _Requirements: 6.1, 6.6_

- [ ] 4. MVP pages (6 pages)
  - [x] 4.1 Home page (index.astro)
    - Create hero section with gradient background
    - Add navigation grid with 5 tiles (Buttons, Popups, Theme, Navigation, Integrations)
    - Add ThemeSwitcher component
    - Apply transition:name to tiles
    - _Requirements: 8.1_
  
  - [x] 4.2 Buttons page (buttons.astro)
    - Create ButtonDemo island component
    - Demonstrate MainButton (show, hide, setText, onClick)
    - Demonstrate BackButton (show, hide, onClick)
    - Add code snippets
    - _Requirements: 2.6, 2.7, 8.2_
  
  - [x] 4.3 Popups page (popups.astro)
    - Create PopupDemo island component
    - Demonstrate showPopup with custom buttons
    - Demonstrate showAlert
    - Demonstrate showConfirm
    - _Requirements: 2.8, 8.3_
  
  - [x] 4.4 Theme page (theme.astro)
    - Display current themeParams values
    - Show CSS variables for each theme mode
    - Add ThemeSwitcher component
    - Demonstrate theme reactivity
    - _Requirements: 2.3, 6.5, 8.5_
  
  - [x] 4.5 Navigation page (navigation.astro)
    - Demonstrate View Transitions between pages
    - Show shared element transitions with transition:name
    - Show persistent elements with transition:persist
    - _Requirements: 4.2, 4.3, 4.4, 8.7_
  
  - [x] 4.6 Integrations page (integrations.astro)
    - Create IntegrationsDemo island component
    - Show auth status (user info from API)
    - Demonstrate preferences get/update
    - Show round-trip: update → reload → restored
    - _Requirements: 3.1, 3.2, 10.1, 10.2, 8.11_

- [ ] 5. Reusable UI components
  - [x] 5.1 ThemeSwitcher island (Svelte)
    - Add buttons for Native, Premium, Mixed modes
    - Integrate with theme.ts module
    - Add visual indicator for current theme
    - Call theme.set() on click (syncs to DB)
    - _Requirements: 6.7_
  
  - [x] 5.2 DemoCard component (Astro)
    - Apply glass morphism effect
    - Add large border radius (16px minimum)
    - Add soft shadows
    - Add hover glow effect
    - _Requirements: 1.3, 1.4, 1.5, 1.7_


- [ ] 6. FastAPI backend (complete implementation)
  - [x] 6.1 Project structure and configuration
    - Create apps/api/app/ directory structure
    - Create app/main.py with FastAPI app and lifespan
    - Create app/config.py with Settings (pydantic-settings)
    - Create app/database.py with get_db_pool() dependency
    - Create app/auth.py with JWT functions
    - Create app/models.py with Pydantic models
    - Create requirements.txt with FastAPI, asyncpg, python-jose, pydantic-settings
    - _Requirements: 10.4, 10.7_
  
  - [x] 6.2 CORS configuration
    - Add CORSMiddleware to main.py
    - Set allow_origins from settings.ALLOWED_ORIGINS (explicit list, NOT "*")
    - Set allow_credentials=True (required for cookies)
    - CRITICAL: allow_credentials=True REQUIRES explicit origins (not "*")
    - Set allow_methods=["*"] and allow_headers=["*"]
    - _Requirements: 3.9, 10.8_
  
  - [x] 6.3 Database connection pool
    - Implement lifespan context manager in main.py
    - Create asyncpg.create_pool() on startup (min_size=5, max_size=20)
    - Close pool on shutdown
    - Implement get_db_pool() dependency function
    - _Requirements: 10.5_
  
  - [x] 6.4 Authentication router (auth.py)
    - Implement validate_init_data() function (HMAC-SHA256 + auth_date TTL check)
    - Implement POST /api/auth/validate endpoint
    - Parse user data from initData
    - Upsert user in database
    - Generate JWT token with create_access_token()
    - Set HttpOnly cookie in response (domain, path, SameSite, Secure, max_age)
    - Return user info (no token in body)
    - Add logging for auth attempts
    - _Requirements: 3.1, 3.3, 3.6, 3.8, 10.1, 10.9_
  
  - [x] 6.5 Preferences router (prefs.py)
    - Implement GET /api/preferences endpoint
    - Implement PUT /api/preferences endpoint
    - Extract user_id from session cookie
    - Query/update user_preferences table
    - Return defaults if no preferences exist
    - Add error handling for invalid cookies
    - _Requirements: 10.2_
  
  - [x] 6.6 Health check router (health.py)
    - Implement GET /api/health endpoint
    - Check database connection with SELECT 1
    - Return status and database state
    - No authentication required
    - _Requirements: 3.7, 10.3_
  
  - [x] 6.7 Error handling and logging
    - Add try-catch blocks for all endpoints
    - Return appropriate HTTP status codes (400, 401, 404, 500)
    - Add logging for errors and important events
    - Configure logging.basicConfig(level=logging.INFO)
    - _Requirements: 10.6_

- [ ] 7. Database setup (Supabase Postgres)
  - [x] 7.1 Create migration SQL
    - Create apps/api/migrations/001_initial.sql
    - Define users table (id, telegram_id, first_name, last_name, username, timestamps)
    - Define user_preferences table (id, user_id, theme_mode, reduced_motion, timestamps)
    - Add indexes on telegram_id and user_id
    - Add foreign key constraint with ON DELETE CASCADE
    - _Requirements: 10.5_
  
  - [~] 7.2 Apply migration
    - Connect to Supabase database
    - Run psql $DATABASE_URL -f migrations/001_initial.sql
    - Verify tables created successfully
    - _Requirements: 10.5_

- [ ] 8. Telegram bot (aiogram 3.x)
  - [x] 8.1 Bot implementation
    - Create apps/bot/bot.py
    - Load BOT_TOKEN and WEB_APP_URL from environment (with validation)
    - Initialize Bot and Dispatcher
    - Create /start command handler
    - Create InlineKeyboardMarkup with WebAppInfo button
    - Send welcome message with keyboard
    - Add error handling and logging
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_
  
  - [x] 8.2 Bot dependencies
    - Create requirements.txt with aiogram==3.24.0, python-dotenv
    - Create .env.example with BOT_TOKEN and WEB_APP_URL
    - _Requirements: 11.4_

- [ ] 9. Production deployment (VDS Ubuntu 24.04)
  - [~] 9.1 VDS initial setup
    - Update system: apt update && apt upgrade
    - Install Nginx: apt install nginx
    - Install Python 3.12: apt install python3.12 python3.12-venv
    - Install Node.js 20: install via nvm or apt
    - Install PostgreSQL client: apt install postgresql-client
    - Install certbot: apt install certbot python3-certbot-nginx
    - _Requirements: 15.1_
  
  - [~] 9.2 Deploy application code
    - Create /opt/tma-studio directory
    - Clone repository to /opt/tma-studio
    - Create Python venv: python3.12 -m venv /opt/tma-studio/venv
    - Install API dependencies: venv/bin/pip install -r apps/api/requirements.txt
    - Install bot dependencies: venv/bin/pip install -r apps/bot/requirements.txt
    - Install web dependencies: cd apps/web && npm install
    - Build web app: npm run build
    - Copy dist/ to /var/www/tma-studio/
    - _Requirements: 15.2_
  
  - [~] 9.3 Configure environment variables
    - Create /opt/tma-studio/apps/api/.env with production values
    - Create /opt/tma-studio/apps/bot/.env with production values
    - Create /opt/tma-studio/apps/web/.env with PUBLIC_API_URL=https://api.yourdomain.com
    - Set file permissions: chmod 600 .env files
    - Verify BOT_TOKEN, DATABASE_URL, JWT_SECRET, ALLOWED_ORIGINS, COOKIE_DOMAIN
    - _Requirements: 15.9, 15.10_
  
  - [~] 9.4 Apply database migrations
    - Run psql $DATABASE_URL -f /opt/tma-studio/apps/api/migrations/001_initial.sql
    - Verify tables created
    - _Requirements: 15.8_
  
  - [~] 9.5 Configure Nginx
    - Create /etc/nginx/sites-available/tma-studio-app
    - Configure app.yourdomain.com to serve /var/www/tma-studio/dist
    - Create /etc/nginx/sites-available/tma-studio-api
    - Configure api.yourdomain.com to proxy_pass http://127.0.0.1:8000
    - Add proxy headers (X-Real-IP, X-Forwarded-For, X-Forwarded-Proto)
    - Enable sites: ln -s sites-available/* sites-enabled/
    - Test config: nginx -t
    - Reload Nginx: systemctl reload nginx
    - _Requirements: 15.2, 15.3, 15.4_
  
  - [~] 9.6 Configure SSL (Let's Encrypt)
    - Run certbot --nginx -d app.yourdomain.com -d api.yourdomain.com
    - Verify HTTPS works
    - Test auto-renewal: certbot renew --dry-run
    - _Requirements: 15.5, 15.11_
  
  - [~] 9.7 Configure systemd services
    - Create /etc/systemd/system/tma-studio-api.service
    - Create /etc/systemd/system/tma-studio-bot.service
    - Set User=www-data, WorkingDirectory, Environment, ExecStart
    - Add --proxy-headers flag to uvicorn (for correct https scheme detection)
    - Set Restart=always, RestartSec=10
    - Reload systemd: systemctl daemon-reload
    - Enable services: systemctl enable tma-studio-api tma-studio-bot
    - Start services: systemctl start tma-studio-api tma-studio-bot
    - Check status: systemctl status tma-studio-api tma-studio-bot
    - _Requirements: 15.6, 15.7, 15.12_
  
  - [~] 9.8 Verify deployment
    - Test health check: curl https://api.yourdomain.com/api/health
    - Test frontend: open https://app.yourdomain.com in browser
    - Test bot: send /start command in Telegram
    - Test Mini App: click web_app button
    - Test auth: verify initData validation works
    - Test preferences: save theme, reload, verify restored
    - _Requirements: All_

- [ ] 10. Documentation
  - [x] 10.1 Deployment guide (docs/deployment.md)
    - Document VDS setup steps
    - Document Nginx configuration
    - Document SSL setup with Let's Encrypt
    - Document systemd service configuration
    - Document environment variables
    - Document database migration
    - Document troubleshooting steps
    - _Requirements: 13.7, 15.13_
  
  - [x] 10.2 Update README.md
    - Add deployment instructions
    - Document all environment variables
    - Add local development setup
    - Add smoke test procedure
    - _Requirements: 13.1, 13.6_
  
  - [x] 10.3 Telegram standards (docs/telegram-standards.md)
    - Document Mini Apps best practices
    - Add links to official Telegram documentation
    - Include initData validation algorithm
    - Include common pitfalls and solutions
    - _Requirements: 13.2, 13.5_

- [ ] 11. Smoke test (end-to-end)
  - Open Telegram bot
  - Send /start command
  - Click "Open TMA Studio" button
  - Verify Mini App loads in Telegram
  - Verify no console errors
  - Change theme to "native"
  - Verify theme changes
  - Reload page
  - Verify theme persisted (from database)
  - Navigate between pages
  - Verify View Transitions work
  - Test MainButton and BackButton
  - Test popups (alert, confirm)
  - _Requirements: All_


## PHASE 2: Showcase Expansion

### Definition of Done (Phase 2)
- [ ] 5 additional pages implemented (Haptics, Viewport Lab, Motion, Forms, Cards)
- [ ] Motion.dev animations showcase (1-2 impressive scenes)
- [ ] Haptics demo with all feedback types
- [ ] Viewport Lab with live metrics
- [ ] Forms page with validation UX
- [ ] Cards page with premium designs
- [ ] Deep links scenarios demonstrated
- [ ] All pages work in light/dark Telegram themes

### Tasks (Phase 2)

- [ ] 1. Additional demo pages
  - [ ] 1.1 Haptics page (haptics.astro)
    - Demonstrate impact feedback (light, medium, heavy, rigid, soft)
    - Demonstrate notification feedback (error, success, warning)
    - Demonstrate selection feedback
    - Add interactive buttons for each type
    - _Requirements: 2.9, 8.4_
  
  - [ ] 1.2 Viewport & Safe Area Lab (viewport.astro)
    - Display current viewport height and stable height
    - Display safe area insets
    - Add visual indicators for safe areas
    - Demonstrate layout behavior on viewport changes
    - Use dvh and svh units
    - _Requirements: 2.4, 2.5, 7.1, 7.2, 7.3, 8.6_
  
  - [ ] 1.3 Motion Showcase (motion.astro)
    - Create 1-2 impressive animation scenes using Motion.dev
    - Use animate() function in Svelte islands
    - Limit to hardware-accelerated properties
    - Add reduced motion fallbacks
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 8.10_
  
  - [ ] 1.4 Forms page (forms.astro)
    - Create input components with focus states
    - Add validation UX examples
    - Add error state designs
    - Demonstrate accessible form patterns
    - _Requirements: 8.9_
  
  - [ ] 1.5 Cards & Lists page (cards.astro)
    - Create premium card designs with glass morphism
    - Add skeleton loading states
    - Add empty state designs
    - Demonstrate list layouts
    - _Requirements: 1.3, 1.4, 1.5, 8.8_

- [ ] 2. Deep links and advanced integrations
  - Implement deep link handling
  - Add QR code generation for sharing
  - Demonstrate data passing between bot and Mini App
  - _Requirements: 8.11_

- [ ] 3. Visual polish
  - Add noise texture overlays to gradients
  - Refine glow effects and shadows
  - Improve typography and spacing
  - Add loading states and transitions
  - _Requirements: 1.1, 1.5, 1.6_

## PHASE 3: Quality & Testing

### Definition of Done (Phase 3)
- [ ] Unit tests pass (frontend + backend)
- [ ] Property-based tests pass (optional)
- [ ] Lighthouse score > 90
- [ ] FCP < 2s on 3G
- [ ] TTI < 4s on 3G
- [ ] Bundle size < 150KB initial JS
- [ ] Error monitoring configured (Sentry)
- [ ] Analytics configured (optional)

### Tasks (Phase 3)

- [ ] 1. Frontend unit tests
  - Test tg.ts adapter with mocked Telegram API
  - Test api.ts client with mocked fetch
  - Test theme.ts with mocked localStorage and API
  - Test Svelte components (ThemeSwitcher, ButtonDemo, etc.)
  - _Requirements: 14.1_

- [ ] 2. Backend unit tests
  - Test initData validation with known valid/invalid inputs
  - Test JWT creation and decoding
  - Test CORS configuration
  - Test health check endpoint
  - Test preferences CRUD operations
  - _Requirements: 14.1_

- [ ] 3. Property-based tests (optional)
  - Frontend: Theme persistence round-trip (fast-check)
  - Backend: InitData HMAC validation (Hypothesis)
  - Backend: JWT expiration (Hypothesis)
  - Backend: Preferences round-trip (Hypothesis)
  - _Requirements: None (optional)_

- [ ] 4. Performance optimization
  - Run Lighthouse CI
  - Optimize images (WebP/AVIF with srcset)
  - Implement lazy loading for below-fold content
  - Minimize bundle size
  - Add compression (gzip/brotli)
  - _Requirements: 9.1, 9.2, 9.4, 9.5, 9.6, 9.7_

- [ ] 5. Monitoring and analytics
  - Configure Sentry for error tracking
  - Add Web Vitals monitoring
  - Configure analytics (optional)
  - Add logging and alerting
  - _Requirements: None (Phase 3)_

## Notes

### Critical Rules for Phase 1
- NO property-based tests in Phase 1 (deferred to Phase 3)
- NO mock backend in Phase 1 (real FastAPI + Postgres)
- NO Motion.dev in Phase 1 (deferred to Phase 2)
- NO strict performance SLA in Phase 1 (measured in Phase 3)
- Focus on: functionality, deployment, smoke test passing

### Secrets Management
- ALL secrets in environment variables
- NEVER commit .env files
- File permissions: chmod 600 .env
- Use .env.example with placeholders
- Generate JWT_SECRET with: openssl rand -base64 32

### Deployment Checklist
- [ ] DNS records point to VDS IP
- [ ] Nginx configured for both domains
- [ ] SSL certificates installed (Let's Encrypt)
- [ ] Systemd services enabled and running
- [ ] Database migrations applied
- [ ] Environment variables set correctly
- [ ] Health check responds
- [ ] Smoke test passes

