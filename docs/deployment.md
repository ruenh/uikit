# TMA Studio Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying TMA Studio to a VDS (Virtual Dedicated Server) running Ubuntu 24.04. The deployment includes:

- **Frontend**: Astro static site served via Nginx at `app.yourdomain.com`
- **Backend**: FastAPI application proxied via Nginx at `api.yourdomain.com`
- **Bot**: aiogram Telegram bot running as systemd service
- **Database**: PostgreSQL (Supabase or self-hosted)
- **SSL**: HTTPS certificates via Let's Encrypt
- **Process Management**: systemd services with auto-restart

## Prerequisites

Before starting, ensure you have:

- [ ] VDS with Ubuntu 24.04 installed
- [ ] Root or sudo access to the VDS
- [ ] Two domain names configured:
  - `app.yourdomain.com` (for frontend)
  - `api.yourdomain.com` (for backend)
- [ ] DNS A records pointing both domains to your VDS IP address
- [ ] Telegram bot token from [@BotFather](https://t.me/BotFather)
- [ ] PostgreSQL database (Supabase recommended or self-hosted)
- [ ] Database connection URL with credentials

## Architecture Overview

```
Internet
    │
    ├─→ app.yourdomain.com (HTTPS:443)
    │       │
    │       └─→ Nginx → /var/www/tma-studio/dist (static files)
    │
    └─→ api.yourdomain.com (HTTPS:443)
            │
            └─→ Nginx → FastAPI (127.0.0.1:8000)
                    │
                    ├─→ PostgreSQL Database
                    └─→ Telegram Bot (systemd service)
```

---

## Step 1: Initial VDS Setup

### 1.1 Update System Packages

```bash
# Connect to your VDS via SSH
ssh root@your-vds-ip

# Update package lists and upgrade installed packages
apt update && apt upgrade -y
```

### 1.2 Install Required Software

```bash
# Install Nginx web server
apt install nginx -y

# Install Python 3.12 and venv
apt install python3.12 python3.12-venv python3-pip -y

# Install PostgreSQL client (for running migrations)
apt install postgresql-client -y

# Install Git
apt install git -y

# Install Certbot for Let's Encrypt SSL certificates
apt install certbot python3-certbot-nginx -y
```

### 1.3 Install Node.js 20

```bash
# Install Node.js using NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install nodejs -y

# Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

### 1.4 Create Application Directory

```bash
# Create directory for application
mkdir -p /opt/tma-studio
cd /opt/tma-studio
```

---

## Step 2: Deploy Application Code

### 2.1 Clone Repository

```bash
# Clone your repository (replace with your repo URL)
git clone https://github.com/yourusername/tma-studio.git /opt/tma-studio

# Or upload files via SCP/SFTP if not using Git
```

### 2.2 Set Up Python Virtual Environment

```bash
cd /opt/tma-studio

# Create virtual environment
python3.12 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install API dependencies
pip install -r apps/api/requirements.txt

# Install bot dependencies
pip install -r apps/bot/requirements.txt

# Deactivate virtual environment
deactivate
```

### 2.3 Build Frontend Application

```bash
cd /opt/tma-studio/apps/web

# Install dependencies
npm install

# Build for production
npm run build

# Create web root directory
mkdir -p /var/www/tma-studio

# Copy built files to web root
cp -r dist/* /var/www/tma-studio/

# Set proper permissions
chown -R www-data:www-data /var/www/tma-studio
```

---

## Step 3: Configure Environment Variables

### 3.1 API Environment Variables

Create `/opt/tma-studio/apps/api/.env`:

```bash
nano /opt/tma-studio/apps/api/.env
```

Add the following content (replace with your actual values):

```env
# Telegram Bot Token (get from @BotFather)
BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz

# Database Connection (Supabase or self-hosted PostgreSQL)
DATABASE_URL=postgresql://user:password@db.supabase.co:5432/postgres

# JWT Secret (generate with: openssl rand -base64 32)
JWT_SECRET=your-random-secret-key-min-32-chars-here
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# InitData Validation Settings
# Default: 86400 (24 hours) for demo/development
# Production recommendation: 300-600 seconds (5-10 minutes) for tighter security
INIT_DATA_MAX_AGE_SECONDS=86400

# CORS Configuration
# CRITICAL: Must be explicit list (not "*") when using credentials
ALLOWED_ORIGINS=["https://app.yourdomain.com"]

# Cookie Settings
COOKIE_DOMAIN=.yourdomain.com
COOKIE_SECURE=true
COOKIE_SAMESITE=none
COOKIE_MAX_AGE=86400
```

**Security Note**: Generate a strong JWT secret:
```bash
openssl rand -base64 32
```

### 3.2 Bot Environment Variables

Create `/opt/tma-studio/apps/bot/.env`:

```bash
nano /opt/tma-studio/apps/bot/.env
```

Add the following content:

```env
# Telegram Bot Token (same as API)
BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz

# Web App URL (your frontend domain)
WEB_APP_URL=https://app.yourdomain.com
```

### 3.3 Frontend Environment Variables

Create `/opt/tma-studio/apps/web/.env`:

```bash
nano /opt/tma-studio/apps/web/.env
```

Add the following content:

```env
# API URL for production
PUBLIC_API_URL=https://api.yourdomain.com
```

**Note**: You'll need to rebuild the frontend after setting this variable.

### 3.4 Secure Environment Files

```bash
# Set restrictive permissions (owner read/write only)
chmod 600 /opt/tma-studio/apps/api/.env
chmod 600 /opt/tma-studio/apps/bot/.env
chmod 600 /opt/tma-studio/apps/web/.env

# Set ownership to www-data
chown www-data:www-data /opt/tma-studio/apps/api/.env
chown www-data:www-data /opt/tma-studio/apps/bot/.env
```

---

## Step 4: Database Setup

### 4.1 Apply Database Migrations

```bash
# Set DATABASE_URL environment variable
export DATABASE_URL="postgresql://user:password@db.supabase.co:5432/postgres"

# Apply migration
psql $DATABASE_URL -f /opt/tma-studio/apps/api/migrations/001_initial.sql
```

### 4.2 Verify Tables Created

```bash
# Connect to database
psql $DATABASE_URL

# List tables
\dt

# You should see:
# - users
# - user_preferences

# Exit psql
\q
```

---

## Step 5: Configure Nginx

### 5.1 Frontend Configuration

Create `/etc/nginx/sites-available/tma-studio-app`:

```bash
nano /etc/nginx/sites-available/tma-studio-app
```

Add the following configuration:

```nginx
# Frontend configuration for app.yourdomain.com

server {
    listen 80;
    server_name app.yourdomain.com;
    
    # Redirect HTTP to HTTPS (will be configured by Certbot)
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app.yourdomain.com;

    
    # SSL certificates (will be configured by Certbot)
    ssl_certificate /etc/letsencrypt/live/app.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.yourdomain.com/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Root directory for static files
    root /var/www/tma-studio;
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
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

### 5.2 Backend Configuration

Create `/etc/nginx/sites-available/tma-studio-api`:

```bash
nano /etc/nginx/sites-available/tma-studio-api
```

Add the following configuration:

```nginx
# Backend configuration for api.yourdomain.com

server {
    listen 80;
    server_name api.yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;
    
    # SSL certificates (will be configured by Certbot)
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
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
        
        # WebSocket support (if needed in future)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 5.3 Enable Sites

```bash
# Create symbolic links to enable sites
ln -s /etc/nginx/sites-available/tma-studio-app /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/tma-studio-api /etc/nginx/sites-enabled/

# Test Nginx configuration
nginx -t

# If test passes, reload Nginx
systemctl reload nginx
```

---

## Step 6: Configure SSL with Let's Encrypt

### 6.1 Obtain SSL Certificates

```bash
# Run Certbot for both domains
certbot --nginx -d app.yourdomain.com -d api.yourdomain.com

# Follow the prompts:
# - Enter your email address
# - Agree to terms of service
# - Choose whether to redirect HTTP to HTTPS (recommended: Yes)
```

### 6.2 Verify SSL Configuration

```bash
# Test certificate renewal
certbot renew --dry-run

# Check certificate expiration
certbot certificates
```

### 6.3 Auto-Renewal

Certbot automatically sets up a systemd timer for renewal. Verify it's enabled:

```bash
systemctl status certbot.timer
```

---

## Step 7: Configure systemd Services


### 7.1 API Service

Create `/etc/systemd/system/tma-studio-api.service`:

```bash
nano /etc/systemd/system/tma-studio-api.service
```

Add the following configuration:

```ini
[Unit]
Description=TMA Studio FastAPI Backend
After=network.target postgresql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/tma-studio/apps/api
Environment="PATH=/opt/tma-studio/venv/bin"
EnvironmentFile=/opt/tma-studio/apps/api/.env

# --proxy-headers: Trust X-Forwarded-* headers from Nginx
# Required for: secure cookies (https scheme), CORS origin validation
ExecStart=/opt/tma-studio/venv/bin/uvicorn app.main:app \
    --host 127.0.0.1 \
    --port 8000 \
    --workers 4 \
    --proxy-headers

# Restart policy
Restart=always
RestartSec=10

# Logging
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### 7.2 Bot Service

Create `/etc/systemd/system/tma-studio-bot.service`:

```bash
nano /etc/systemd/system/tma-studio-bot.service
```

Add the following configuration:

```ini
[Unit]
Description=TMA Studio Telegram Bot
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/tma-studio/apps/bot
Environment="PATH=/opt/tma-studio/venv/bin"
EnvironmentFile=/opt/tma-studio/apps/bot/.env

ExecStart=/opt/tma-studio/venv/bin/python bot.py

# Restart policy
Restart=always
RestartSec=10

# Logging
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```


### 7.3 Enable and Start Services

```bash
# Reload systemd to recognize new services
systemctl daemon-reload

# Enable services to start on boot
systemctl enable tma-studio-api.service
systemctl enable tma-studio-bot.service

# Start services
systemctl start tma-studio-api.service
systemctl start tma-studio-bot.service

# Check service status
systemctl status tma-studio-api.service
systemctl status tma-studio-bot.service
```

### 7.4 View Service Logs

```bash
# View API logs
journalctl -u tma-studio-api.service -f

# View bot logs
journalctl -u tma-studio-bot.service -f

# View last 100 lines
journalctl -u tma-studio-api.service -n 100
```

---

## Step 8: Verification

### 8.1 Health Check

Test the API health endpoint:

```bash
curl https://api.yourdomain.com/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "database": "connected"
}
```

### 8.2 Frontend Access

Open your browser and navigate to:
```
https://app.yourdomain.com
```

You should see the TMA Studio home page.

### 8.3 Bot Test

1. Open Telegram and find your bot
2. Send `/start` command
3. Click the "Open TMA Studio" button
4. Verify the Mini App loads inside Telegram

### 8.4 End-to-End Test

1. Open Mini App in Telegram
2. Navigate to the Integrations page
3. Verify authentication works (user info displayed)
4. Change theme preference
5. Reload the page
6. Verify theme preference persisted (loaded from database)

---

## Step 9: Post-Deployment Configuration


### 9.1 Configure Firewall (UFW)

```bash
# Enable UFW if not already enabled
ufw --force enable

# Allow SSH (important - don't lock yourself out!)
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Check status
ufw status
```

### 9.2 Set Up Log Rotation

Create `/etc/logrotate.d/tma-studio`:

```bash
nano /etc/logrotate.d/tma-studio
```

Add the following configuration:

```
/var/log/nginx/app.yourdomain.com*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
    endscript
}

/var/log/nginx/api.yourdomain.com*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
    endscript
}
```

### 9.3 Configure Telegram Bot Settings

In Telegram, talk to [@BotFather](https://t.me/BotFather):

1. Set bot description: `/setdescription`
2. Set bot about text: `/setabouttext`
3. Set bot profile picture: `/setuserpic`
4. Configure menu button: `/setmenubutton` → Select your bot → Choose "Web App" → Enter `https://app.yourdomain.com`

---

## Troubleshooting

### Issue: API Returns 502 Bad Gateway

**Symptoms**: Nginx shows 502 error when accessing API

**Possible Causes**:
1. FastAPI service not running
2. FastAPI listening on wrong port
3. Firewall blocking internal connections

**Solutions**:
```bash
# Check if API service is running
systemctl status tma-studio-api.service

# Check if port 8000 is listening
netstat -tlnp | grep 8000
# or
ss -tlnp | grep 8000

# Check API logs for errors
journalctl -u tma-studio-api.service -n 50

# Restart API service
systemctl restart tma-studio-api.service
```


### Issue: Database Connection Failed

**Symptoms**: API health check shows "unhealthy", logs show database connection errors

**Possible Causes**:
1. Incorrect DATABASE_URL
2. Database server not accessible
3. Firewall blocking database port
4. SSL/TLS connection issues

**Solutions**:
```bash
# Test database connection manually
psql $DATABASE_URL -c "SELECT 1"

# Check if DATABASE_URL is set correctly
cat /opt/tma-studio/apps/api/.env | grep DATABASE_URL

# For Supabase, ensure connection pooling is enabled
# Use connection string with port 6543 for pooling:
# postgresql://user:password@db.supabase.co:6543/postgres

# Check API logs for specific error
journalctl -u tma-studio-api.service | grep -i database
```

### Issue: Bot Not Responding

**Symptoms**: Bot doesn't respond to /start command

**Possible Causes**:
1. Bot service not running
2. Invalid BOT_TOKEN
3. Network connectivity issues
4. Bot token revoked

**Solutions**:
```bash
# Check bot service status
systemctl status tma-studio-bot.service

# Check bot logs
journalctl -u tma-studio-bot.service -n 50

# Verify BOT_TOKEN is correct
cat /opt/tma-studio/apps/bot/.env | grep BOT_TOKEN

# Test bot token with Telegram API
curl https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getMe

# Restart bot service
systemctl restart tma-studio-bot.service
```

### Issue: CORS Errors in Browser Console

**Symptoms**: Browser console shows CORS policy errors when calling API

**Possible Causes**:
1. ALLOWED_ORIGINS not configured correctly
2. Frontend domain not matching ALLOWED_ORIGINS
3. Missing credentials in fetch requests

**Solutions**:
```bash
# Check ALLOWED_ORIGINS in API .env
cat /opt/tma-studio/apps/api/.env | grep ALLOWED_ORIGINS

# Ensure it matches your frontend domain exactly:
# ALLOWED_ORIGINS=["https://app.yourdomain.com"]

# Restart API after changing .env
systemctl restart tma-studio-api.service
```

**Frontend Check**:
Ensure all API calls include `credentials: 'include'`:
```typescript
fetch('https://api.yourdomain.com/api/endpoint', {
  credentials: 'include',
  // ... other options
})
```


### Issue: SSL Certificate Errors

**Symptoms**: Browser shows "Your connection is not private" or certificate errors

**Possible Causes**:
1. Certbot failed to obtain certificates
2. Nginx not configured to use certificates
3. DNS not pointing to correct server

**Solutions**:
```bash
# Check certificate status
certbot certificates

# Verify DNS records
dig app.yourdomain.com
dig api.yourdomain.com

# Re-run Certbot
certbot --nginx -d app.yourdomain.com -d api.yourdomain.com

# Check Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

### Issue: Cookies Not Being Set

**Symptoms**: Authentication works but session not persisted, cookies not visible in browser

**Possible Causes**:
1. COOKIE_SECURE=true but using HTTP (not HTTPS)
2. COOKIE_DOMAIN mismatch
3. SameSite=None without Secure flag
4. Browser blocking third-party cookies

**Solutions**:
```bash
# Verify HTTPS is working
curl -I https://api.yourdomain.com/api/health

# Check cookie settings in .env
cat /opt/tma-studio/apps/api/.env | grep COOKIE

# Ensure these settings for cross-domain cookies:
# COOKIE_DOMAIN=.yourdomain.com
# COOKIE_SECURE=true
# COOKIE_SAMESITE=none

# Restart API
systemctl restart tma-studio-api.service
```

**Browser Check**:
- Open DevTools → Application → Cookies
- Verify cookie is set with correct domain and flags
- Check that Secure and SameSite=None flags are present

### Issue: InitData Validation Failed

**Symptoms**: API returns 401 Unauthorized, logs show "Invalid authentication data"

**Possible Causes**:
1. BOT_TOKEN mismatch between bot and API
2. InitData expired (auth_date too old)
3. InitData tampered with
4. Clock skew between server and Telegram

**Solutions**:
```bash
# Verify BOT_TOKEN matches in both services
diff <(cat /opt/tma-studio/apps/api/.env | grep BOT_TOKEN) \
     <(cat /opt/tma-studio/apps/bot/.env | grep BOT_TOKEN)

# Check server time
date -u

# Adjust INIT_DATA_MAX_AGE_SECONDS if needed
# In /opt/tma-studio/apps/api/.env:
# INIT_DATA_MAX_AGE_SECONDS=86400  # 24 hours for development
# INIT_DATA_MAX_AGE_SECONDS=600    # 10 minutes for production

# Check API logs for specific validation error
journalctl -u tma-studio-api.service | grep -i "validation failed"
```


### Issue: Frontend Shows Blank Page

**Symptoms**: Accessing app.yourdomain.com shows blank page or 404 errors

**Possible Causes**:
1. Build files not copied to /var/www/tma-studio
2. Nginx not serving correct directory
3. Missing index.html
4. Incorrect file permissions

**Solutions**:
```bash
# Check if files exist
ls -la /var/www/tma-studio/

# Verify index.html exists
ls -la /var/www/tma-studio/index.html

# Check file permissions
ls -la /var/www/tma-studio/

# Fix permissions if needed
chown -R www-data:www-data /var/www/tma-studio/
chmod -R 755 /var/www/tma-studio/

# Rebuild and redeploy frontend
cd /opt/tma-studio/apps/web
npm run build
rm -rf /var/www/tma-studio/*
cp -r dist/* /var/www/tma-studio/

# Check Nginx error logs
tail -f /var/log/nginx/error.log
```

---

## Maintenance

### Updating the Application

```bash
# 1. Pull latest code
cd /opt/tma-studio
git pull origin main

# 2. Update backend dependencies (if changed)
source venv/bin/activate
pip install -r apps/api/requirements.txt
pip install -r apps/bot/requirements.txt
deactivate

# 3. Apply new database migrations (if any)
psql $DATABASE_URL -f apps/api/migrations/002_new_migration.sql

# 4. Rebuild frontend
cd apps/web
npm install  # if package.json changed
npm run build
rm -rf /var/www/tma-studio/*
cp -r dist/* /var/www/tma-studio/

# 5. Restart services
systemctl restart tma-studio-api.service
systemctl restart tma-studio-bot.service

# 6. Verify deployment
curl https://api.yourdomain.com/api/health
```

### Monitoring Service Health

```bash
# Check all services
systemctl status tma-studio-api.service
systemctl status tma-studio-bot.service
systemctl status nginx.service

# View recent logs
journalctl -u tma-studio-api.service --since "1 hour ago"
journalctl -u tma-studio-bot.service --since "1 hour ago"

# Monitor logs in real-time
journalctl -u tma-studio-api.service -f
```


### Database Backup

```bash
# Create backup directory
mkdir -p /opt/backups/tma-studio

# Manual backup
pg_dump $DATABASE_URL > /opt/backups/tma-studio/backup-$(date +%Y%m%d-%H%M%S).sql

# Automated daily backup (add to crontab)
crontab -e

# Add this line for daily backup at 2 AM:
0 2 * * * pg_dump $DATABASE_URL > /opt/backups/tma-studio/backup-$(date +\%Y\%m\%d).sql

# Restore from backup
psql $DATABASE_URL < /opt/backups/tma-studio/backup-20240101.sql
```

### Checking Disk Space

```bash
# Check disk usage
df -h

# Check directory sizes
du -sh /opt/tma-studio
du -sh /var/www/tma-studio
du -sh /var/log/nginx
```

---

## Security Checklist

Before going to production, verify all security measures:

- [ ] All `.env` files have 600 permissions (owner read/write only)
- [ ] JWT_SECRET is strong (minimum 32 random characters)
- [ ] HTTPS is enabled with valid SSL certificates
- [ ] HTTP redirects to HTTPS
- [ ] COOKIE_SECURE is set to `true`
- [ ] ALLOWED_ORIGINS contains only your frontend domain (not "*")
- [ ] Database connection uses SSL (Supabase default)
- [ ] Firewall (UFW) is enabled and configured
- [ ] Bot token is never logged or exposed in error messages
- [ ] File permissions are restrictive (no world-readable secrets)
- [ ] systemd services run as www-data (not root)
- [ ] Nginx security headers are configured
- [ ] Regular backups are scheduled
- [ ] Server is updated regularly (`apt update && apt upgrade`)

---

## Environment Variables Reference

### API (.env)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `BOT_TOKEN` | Yes | Telegram bot token from @BotFather | `1234567890:ABC...` |
| `DATABASE_URL` | Yes | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `JWT_SECRET` | Yes | Secret key for JWT signing (min 32 chars) | `generated-with-openssl-rand` |
| `JWT_ALGORITHM` | No | JWT algorithm (default: HS256) | `HS256` |
| `JWT_EXPIRATION_HOURS` | No | Token expiration in hours (default: 24) | `24` |
| `INIT_DATA_MAX_AGE_SECONDS` | No | Max age for initData (default: 86400) | `86400` or `600` |
| `ALLOWED_ORIGINS` | Yes | List of allowed CORS origins | `["https://app.yourdomain.com"]` |
| `COOKIE_DOMAIN` | Yes | Cookie domain for cross-subdomain sharing | `.yourdomain.com` |
| `COOKIE_SECURE` | No | Require HTTPS for cookies (default: true) | `true` |
| `COOKIE_SAMESITE` | No | SameSite policy (default: none) | `none` |
| `COOKIE_MAX_AGE` | No | Cookie max age in seconds (default: 86400) | `86400` |

### Bot (.env)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `BOT_TOKEN` | Yes | Telegram bot token (same as API) | `1234567890:ABC...` |
| `WEB_APP_URL` | Yes | Frontend URL for Mini App | `https://app.yourdomain.com` |

### Frontend (.env)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `PUBLIC_API_URL` | Yes | Backend API URL | `https://api.yourdomain.com` |

---

## Quick Reference Commands

### Service Management
```bash
# Restart all services
systemctl restart tma-studio-api.service tma-studio-bot.service nginx.service

# Stop all services
systemctl stop tma-studio-api.service tma-studio-bot.service

# View service status
systemctl status tma-studio-api.service tma-studio-bot.service
```

### Log Viewing
```bash
# API logs (last 50 lines)
journalctl -u tma-studio-api.service -n 50

# Bot logs (follow in real-time)
journalctl -u tma-studio-bot.service -f

# Nginx error logs
tail -f /var/log/nginx/error.log

# Nginx access logs
tail -f /var/log/nginx/access.log
```

### Testing Endpoints
```bash
# Health check
curl https://api.yourdomain.com/api/health

# Test with verbose output
curl -v https://api.yourdomain.com/api/health

# Test bot token
curl https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getMe
```

---

## Additional Resources

### Official Documentation
- [Telegram Mini Apps Documentation](https://core.telegram.org/bots/webapps)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [systemd Documentation](https://www.freedesktop.org/software/systemd/man/)

### Related Files
- Architecture: `docs/architecture.md`
- Telegram Standards: `docs/telegram-standards.md`
- Main README: `README.md`
- Design Document: `.kiro/specs/tma-studio/design.md`

---

## Support

If you encounter issues not covered in this guide:

1. Check service logs: `journalctl -u tma-studio-api.service -n 100`
2. Check Nginx logs: `tail -f /var/log/nginx/error.log`
3. Verify environment variables are set correctly
4. Ensure DNS records are pointing to correct IP
5. Test each component individually (database, API, bot, frontend)

For Telegram-specific issues, refer to the [Telegram Bot API documentation](https://core.telegram.org/bots/api).

---

**Deployment Guide Version**: 1.0  
**Last Updated**: 2024  
**Target Platform**: Ubuntu 24.04 LTS
