# Requirements Document: TMA Studio

## Introduction

TMA Studio is a premium Telegram Mini App showcase that demonstrates best practices for building Mini Apps with modern web technologies. The application serves as a UX/UI kit and integrations showcase, allowing clients to experience premium design, Telegram-native integration, and engineering excellence within 30-60 seconds of opening the app.

The system consists of three main components:
1. **Web Application**: Astro + Svelte + Tailwind CSS v4 Mini App with premium design
2. **API Backend**: FastAPI service for initData validation and preferences storage
3. **Bot**: Python aiogram 3.x bot for launching the Mini App

## Glossary

- **Mini_App**: A web application that runs inside the Telegram client using the WebApp API
- **Telegram_Client**: The official Telegram application (mobile or desktop) that hosts Mini Apps
- **initData**: Authentication data provided by Telegram to verify user identity and session
- **MainButton**: A prominent button at the bottom of the Mini App controlled by the WebApp API
- **BackButton**: A back navigation button in the Mini App header controlled by the WebApp API
- **Haptics**: Tactile feedback provided through the device's vibration motor
- **Theme_Params**: Color scheme and styling parameters provided by Telegram based on user's theme
- **Viewport**: The visible area of the Mini App within the Telegram client
- **Safe_Area**: The portion of the viewport not obscured by system UI elements
- **View_Transitions**: Animated transitions between pages using shared element morphing
- **Island**: A Svelte component with client-side interactivity in an otherwise static Astro page
- **Bot_Token**: Secret authentication token for the Telegram bot
- **HMAC**: Hash-based Message Authentication Code used for cryptographic verification
- **VDS**: Virtual Dedicated Server for production deployment
- **HttpOnly_Cookie**: Secure cookie that cannot be accessed via JavaScript

## Release Plan

### Phase 1 (MVP) - Production Ready
**Goal**: Full-stack showcase with real backend, deployable to production

**Included Requirements**:
- Requirement 1: Premium Visual Design (simplified - basic gradients/shadows)
- Requirement 2: Telegram WebApp Integration (core features only)
- Requirement 3: Authentication and Security (FULL - critical for MVP)
- Requirement 4: Page Navigation and Transitions (basic View Transitions)
- Requirement 6: Theme System (FULL - core feature)
- Requirement 7: Responsive Layout (basic viewport handling)
- Requirement 8: Demo Sections (5 pages: Home, Buttons, Popups, Theme, Navigation + minimal Integrations)
- Requirement 10: Backend API Architecture (FULL - critical for MVP)
- Requirement 11: Bot Implementation (FULL)
- Requirement 12: Monorepo Structure (FULL)
- Requirement 13: Documentation (deployment focus)
- Requirement 14: Development Experience (basic setup)
- **NEW**: Production Deployment (VDS + Nginx + HTTPS)

**MVP Definition of Done**:
- [ ] Bot opens Mini App in Telegram
- [ ] API validates initData and sets session cookie
- [ ] Preferences save/load from database
- [ ] Theme persists across page reload
- [ ] No console errors in Telegram WebView
- [ ] Deployed on VDS with HTTPS
- [ ] Smoke test passes end-to-end

### Phase 2 (Showcase Expansion)
**Goal**: Additional demo pages and quality improvements

**Included Requirements**:
- Requirement 1: Premium Visual Design (FULL - advanced effects)
- Requirement 2: Telegram WebApp Integration (Haptics demo)
- Requirement 5: Micro-Animations (Motion.dev showcase)
- Requirement 7: Responsive Layout (Viewport Lab page)
- Requirement 8: Demo Sections (remaining pages: Haptics, Viewport Lab, Motion, Forms, Cards)
- Requirement 9: Performance Optimization (measured targets)

### Phase 3 (Quality & Testing)
**Goal**: Testing, monitoring, and optimization

**Included**:
- Unit tests (frontend + backend)
- Property-based tests (optional)
- Lighthouse/Web Vitals optimization
- Error monitoring (Sentry)
- Analytics integration

## Requirements

### Requirement 1: Premium Visual Design

**User Story:** As a potential client, I want to see a visually stunning interface with premium design elements, so that I can evaluate the quality of work and design capabilities.

#### Acceptance Criteria

1. THE Web_App SHALL display gradients with noise texture overlays for depth
2. THE Web_App SHALL apply glow effects to interactive elements on hover states
3. THE Web_App SHALL use glass morphism effects on card components with subtle backdrop blur
4. THE Web_App SHALL implement large border radii (minimum 16px) for modern aesthetic
5. THE Web_App SHALL use soft shadows with multiple layers for depth perception
6. THE Web_App SHALL provide premium typography with appropriate font weights and spacing
7. WHEN a user hovers over interactive elements, THE Web_App SHALL display glow animations
8. THE Web_App SHALL maintain consistent spacing using a systematic scale (4px, 8px, 16px, 24px, 32px, 48px, 64px)

### Requirement 2: Telegram WebApp Integration

**User Story:** As a user, I want the Mini App to feel native to Telegram, so that I have a seamless experience within the Telegram ecosystem.

#### Acceptance Criteria

1. WHEN the Mini App loads, THE Web_App SHALL call Telegram.WebApp.ready() before any other WebApp API calls
2. THE Web_App SHALL implement a tg adapter module that encapsulates all Telegram WebApp API calls
3. WHEN the Telegram theme changes, THE Web_App SHALL update CSS variables to reflect new theme parameters
4. WHEN the viewport height changes, THE Web_App SHALL adjust layout without content jumps or shifts
5. THE Web_App SHALL respect safe area insets to avoid overlap with system UI
6. THE Web_App SHALL provide MainButton demonstrations with text and color customization
7. THE Web_App SHALL provide BackButton demonstrations with show/hide functionality
8. THE Web_App SHALL implement popup demonstrations using showPopup, showAlert, and showConfirm methods
9. THE Web_App SHALL implement haptic feedback demonstrations for impact and notification types
10. THE Web_App SHALL load the official telegram-web-app.js script from Telegram's CDN

### Requirement 3: Authentication and Security **(MVP - Phase 1 - CRITICAL)**

**User Story:** As a system administrator, I want all user data to be verified server-side, so that the application is secure against tampering and impersonation.

#### Acceptance Criteria (MVP)

1. WHEN the Mini App receives initData from Telegram, THE API SHALL validate it using HMAC-SHA256 with the Bot_Token
2. THE Web_App SHALL treat all data from initDataUnsafe as untrusted until server verification
3. THE API SHALL reject requests with invalid or expired initData
4. THE System SHALL store Bot_Token and sensitive credentials only in environment variables
5. THE System SHALL never expose Bot_Token or API secrets in client-side code
6. WHEN initData validation fails, THE API SHALL return a 401 Unauthorized response
7. THE API SHALL implement a health check endpoint that does not require authentication
8. THE API SHALL use HttpOnly cookies for session management (not localStorage)
9. THE API SHALL configure CORS with explicit origins and allow_credentials=True
10. THE System SHALL use HTTPS in production (Let's Encrypt on VDS)

### Requirement 4: Page Navigation and Transitions **(MVP - Phase 1)**

**User Story:** As a user, I want smooth, visually appealing transitions between pages, so that the app feels polished and professional.

#### Acceptance Criteria (MVP)

1. THE Web_App SHALL use Astro View Transitions with the ClientRouter component
2. THE Web_App SHALL implement minimum two shared element transitions using transition:name directive
3. WHEN navigating between pages, THE Web_App SHALL animate shared elements smoothly
4. THE Web_App SHALL use transition:persist directive to maintain state of persistent UI elements
5. WHEN a user has reduced motion preferences enabled, THE Web_App SHALL reduce or disable complex animations

#### Acceptance Criteria (Phase 2)

6. THE Web_App SHALL provide custom transition animations using transition:animate directive
7. THE Web_App SHALL complete page transitions within 200-350ms for perceived performance (measured)

### Requirement 5: Micro-Animations

**User Story:** As a user, I want subtle animations that enhance the interface, so that interactions feel responsive and delightful.

#### Acceptance Criteria

1. THE Web_App SHALL use Motion (motion.dev) animate() function for micro-animations
2. THE Web_App SHALL implement animations only within Svelte islands for minimal bundle size
3. THE Web_App SHALL limit animations to 1-2 "wow" showcase scenes to avoid animation overload
4. WHEN a user has reduced motion preferences enabled, THE Web_App SHALL disable decorative animations
5. THE Web_App SHALL use hardware-accelerated CSS properties (transform, opacity) for animations
6. THE Web_App SHALL complete micro-animations within 200 milliseconds for responsiveness

### Requirement 6: Theme System

**User Story:** As a user, I want the app to adapt to my Telegram theme preferences, so that it feels integrated with my Telegram experience.

#### Acceptance Criteria

1. THE Web_App SHALL provide three theme modes: Native, Premium, and Mixed
2. WHEN in Native mode, THE Web_App SHALL use Telegram's themeParams for all colors
3. WHEN in Premium mode, THE Web_App SHALL use custom premium design colors
4. WHEN in Mixed mode, THE Web_App SHALL blend Telegram theme colors with premium design elements
5. WHEN Telegram theme changes, THE Web_App SHALL update CSS custom properties dynamically
6. THE Web_App SHALL persist user's theme preference across sessions
7. THE Web_App SHALL provide a theme switcher UI component accessible from all pages

### Requirement 7: Responsive Layout and Viewport Handling

**User Story:** As a user, I want the app to adapt smoothly to viewport changes, so that I don't experience jarring layout shifts.

#### Acceptance Criteria

1. WHEN the Telegram viewport height changes, THE Web_App SHALL adjust layout smoothly without content jumps
2. THE Web_App SHALL use CSS viewport units (dvh, svh) for dynamic viewport handling
3. THE Web_App SHALL respect safe area insets using env(safe-area-inset-*) CSS variables
4. THE Web_App SHALL implement a Viewport & Safe Area Lab page demonstrating viewport behavior
5. THE Web_App SHALL maintain readable content when keyboard appears or viewport shrinks
6. THE Web_App SHALL use responsive images with appropriate srcset and sizes attributes
7. THE Web_App SHALL optimize images for web delivery with modern formats (WebP, AVIF)

### Requirement 8: Demo Sections and Navigation

**User Story:** As a potential client, I want to explore different integration capabilities through organized demo sections, so that I can understand what's possible with Mini Apps.

#### Acceptance Criteria

1. THE Web_App SHALL provide a home page with navigation tiles to all demo sections
2. THE Web_App SHALL implement a Buttons demo page showcasing MainButton and BackButton
3. THE Web_App SHALL implement a Popups demo page showcasing showPopup, showAlert, and showConfirm
4. THE Web_App SHALL implement a Haptics demo page showcasing impact and notification feedback
5. THE Web_App SHALL implement a Theme demo page showcasing theme switching and CSS variables
6. THE Web_App SHALL implement a Viewport & Safe Area Lab page demonstrating layout behavior
7. THE Web_App SHALL implement a Navigation demo page showcasing View Transitions
8. THE Web_App SHALL implement a Cards & Lists page showcasing premium card designs
9. THE Web_App SHALL implement a Forms page showcasing input validation and focus states
10. THE Web_App SHALL implement a Motion Showcase page with 1-2 impressive animation scenes
11. THE Web_App SHALL implement an Integrations page demonstrating auth and preferences sync

### Requirement 9: Performance Optimization

**User Story:** As a user, I want the app to load quickly and run smoothly, so that I have a responsive experience.

#### Acceptance Criteria (MVP - Phase 1)

1. THE Web_App SHALL use Astro islands architecture to minimize JavaScript bundle size
2. THE Web_App SHALL lazy load demo widgets that are not immediately visible
3. THE Web_App SHALL avoid importing heavy UI libraries when Tailwind components suffice
4. THE Web_App SHALL produce no console errors in Telegram WebView
5. THE Web_App SHALL use code splitting to load page-specific JavaScript only when needed
6. THE Web_App SHALL compress and optimize all static assets (images, fonts, scripts)

#### Acceptance Criteria (Phase 3 - Performance Targets)

**Note**: These are optimization targets/benchmarks for Phase 3, not MVP blockers. Measured for improvement tracking, not pass/fail criteria.

7. Target: First Contentful Paint within 1.5 seconds on 3G networks (measured, not a blocker)
8. Target: Time to Interactive within 3 seconds on 3G networks (measured, not a blocker)
9. Target: Lighthouse score above 90 (measured, not a blocker)
10. Target: Bundle size below 150KB for initial JavaScript load (measured, not a blocker)

### Requirement 10: Backend API Architecture

**User Story:** As a developer, I want a clean API architecture that can be extended for production projects, so that the showcase demonstrates real-world patterns.

#### Acceptance Criteria

1. THE API SHALL provide an endpoint for initData validation that returns user information
2. THE API SHALL provide endpoints for storing and retrieving user preferences
3. THE API SHALL provide a health check endpoint for monitoring
4. THE API SHALL use FastAPI framework with async/await for performance
5. THE API SHALL connect to Supabase (Postgres) for data persistence
6. THE API SHALL implement proper error handling with appropriate HTTP status codes
7. THE API SHALL use environment variables for all configuration (database URL, bot token)
8. THE API SHALL implement CORS configuration to allow requests from the Mini App domain
9. THE API SHALL log all authentication attempts for security monitoring

### Requirement 11: Bot Implementation

**User Story:** As a user, I want to launch the Mini App through a Telegram bot, so that I can access the showcase easily.

#### Acceptance Criteria

1. THE Bot SHALL use aiogram 3.x framework for Telegram Bot API integration
2. WHEN a user sends /start command, THE Bot SHALL respond with a welcome message
3. THE Bot SHALL provide an inline keyboard button with web_app parameter to launch the Mini App
4. THE Bot SHALL use the Bot_Token from environment variables for authentication
5. THE Bot SHALL handle errors gracefully and log failures for debugging

### Requirement 12: Monorepo Structure

**User Story:** As a developer, I want a well-organized monorepo structure, so that I can easily navigate and understand the codebase.

#### Acceptance Criteria

1. THE Repository SHALL organize code into apps/ directory with web, api, and bot subdirectories
2. THE Repository SHALL provide an infra/ directory with docker-compose.yml for local development
3. THE Repository SHALL provide a docs/ directory with architecture, standards, and runbook documentation
4. THE Repository SHALL include a .env.example file documenting all required environment variables
5. THE Repository SHALL include a README.md with setup instructions for all components

### Requirement 13: Documentation

**User Story:** As a developer, I want comprehensive documentation, so that I can understand the architecture and troubleshoot issues.

#### Acceptance Criteria

1. THE Repository SHALL provide README.md with instructions for running web, api, and bot components
2. THE Repository SHALL provide docs/telegram-standards.md with Mini Apps best practices checklist
3. THE Repository SHALL provide docs/architecture.md with module schema and component relationships
4. THE Repository SHALL provide docs/runbook.md with common issues and solutions
5. THE Documentation SHALL include links to official Telegram Mini Apps documentation
6. THE Documentation SHALL document all environment variables with descriptions and example values
7. THE Documentation SHALL provide deployment instructions for production environments

### Requirement 14: Development Experience

**User Story:** As a developer, I want a smooth development experience with hot reload and easy setup, so that I can iterate quickly.

#### Acceptance Criteria

1. THE Web_App SHALL support hot module replacement for instant feedback during development
2. THE System SHALL provide a single docker-compose command to run all services locally
3. THE System SHALL use consistent package managers across all components
4. THE System SHALL provide clear error messages when environment variables are missing
5. THE Web_App SHALL use TypeScript for type safety in Svelte components
6. THE API SHALL use Python type hints for better IDE support and error detection


### Requirement 15: Production Deployment **(MVP - Phase 1 - CRITICAL)**

**User Story:** As a system administrator, I want to deploy the application to a production VDS, so that it is accessible to real users with HTTPS.

#### Acceptance Criteria (MVP)

1. THE System SHALL deploy to VDS Ubuntu 24.04
2. THE System SHALL use Nginx as reverse proxy for frontend and backend
3. THE Frontend SHALL be served from app.yourdomain.com via Nginx
4. THE Backend SHALL be served from api.yourdomain.com via Nginx reverse proxy to FastAPI
5. THE System SHALL use Let's Encrypt for HTTPS certificates
6. THE API SHALL run as systemd service (tma-studio-api.service)
7. THE Bot SHALL run as systemd service (tma-studio-bot.service)
8. THE System SHALL apply database migrations on deployment
9. THE System SHALL store environment variables in /opt/tma-studio/apps/*/. env files
10. THE System SHALL set file permissions to 600 for .env files (owner read/write only)
11. THE Nginx SHALL redirect HTTP to HTTPS
12. THE System SHALL configure systemd services to restart on failure
13. THE System SHALL provide deployment documentation with step-by-step instructions

