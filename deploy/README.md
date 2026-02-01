# TMA Studio Deployment Files

This directory contains all configuration files and scripts needed for production deployment.

## Directory Structure

```
deploy/
├── nginx/              # Nginx configuration files
│   ├── tma-studio-app.conf    # Frontend (app.yourdomain.com)
│   └── tma-studio-api.conf    # Backend (api.yourdomain.com)
├── systemd/            # systemd service files
│   ├── tma-studio-api.service # FastAPI service
│   └── tma-studio-bot.service # Telegram bot service
├── scripts/            # Deployment scripts
│   ├── deploy.sh              # Initial deployment script
│   └── update.sh              # Update script for existing deployment
└── README.md           # This file
```

## Quick Start

### 1. Initial Deployment

```bash
# On your VDS (Ubuntu 24.04)
sudo bash deploy/scripts/deploy.sh
```

This script will:
- Update system packages
- Install all dependencies (Nginx, Python 3.12, Node.js 20, PostgreSQL client, Certbot)
- Clone the repository
- Set up Python virtual environment
- Build the frontend
- Configure Nginx
- Configure systemd services

### 2. Configure Environment Variables

After running the deployment script, configure your environment files:

```bash
# API environment
sudo nano /opt/tma-studio/apps/api/.env

# Bot environment
sudo nano /opt/tma-studio/apps/bot/.env
```

See `.env.example` files for required variables.

### 3. Update Domain Names

Replace `yourdomain.com` with your actual domain in Nginx configs:

```bash
sudo nano /etc/nginx/sites-available/tma-studio-app
sudo nano /etc/nginx/sites-available/tma-studio-api
```

Then reload Nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 4. Apply Database Migrations

```bash
export DATABASE_URL="postgresql://user:password@host:5432/database"
psql $DATABASE_URL -f /opt/tma-studio/apps/api/migrations/001_initial.sql
```

### 5. Configure SSL

```bash
sudo certbot --nginx -d app.yourdomain.com -d api.yourdomain.com
```

### 6. Start Services

```bash
sudo systemctl enable tma-studio-api.service
sudo systemctl enable tma-studio-bot.service
sudo systemctl start tma-studio-api.service
sudo systemctl start tma-studio-bot.service
```

### 7. Verify Deployment

```bash
# Check service status
sudo systemctl status tma-studio-api.service
sudo systemctl status tma-studio-bot.service

# Test health endpoint
curl https://api.yourdomain.com/api/health
```

## Updating the Application

To update an existing deployment:

```bash
sudo bash deploy/scripts/update.sh
```

This will:
- Pull latest code
- Update dependencies
- Rebuild frontend
- Restart services

## Manual Configuration Files

If you prefer manual configuration, use the files in `nginx/` and `systemd/` directories:

### Nginx Configuration

```bash
# Copy Nginx configs
sudo cp deploy/nginx/tma-studio-app.conf /etc/nginx/sites-available/
sudo cp deploy/nginx/tma-studio-api.conf /etc/nginx/sites-available/

# Enable sites
sudo ln -s /etc/nginx/sites-available/tma-studio-app /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/tma-studio-api /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### systemd Services

```bash
# Copy service files
sudo cp deploy/systemd/tma-studio-api.service /etc/systemd/system/
sudo cp deploy/systemd/tma-studio-bot.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start services
sudo systemctl enable tma-studio-api.service tma-studio-bot.service
sudo systemctl start tma-studio-api.service tma-studio-bot.service
```

## Troubleshooting

### View Service Logs

```bash
# API logs
sudo journalctl -u tma-studio-api.service -f

# Bot logs
sudo journalctl -u tma-studio-bot.service -f

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

### Restart Services

```bash
sudo systemctl restart tma-studio-api.service
sudo systemctl restart tma-studio-bot.service
sudo systemctl reload nginx
```

### Check Service Status

```bash
sudo systemctl status tma-studio-api.service
sudo systemctl status tma-studio-bot.service
sudo systemctl status nginx.service
```

## Security Checklist

Before going to production:

- [ ] All `.env` files have 600 permissions
- [ ] JWT_SECRET is strong (32+ random characters)
- [ ] HTTPS is enabled with valid SSL certificates
- [ ] COOKIE_SECURE is set to `true`
- [ ] ALLOWED_ORIGINS contains only your domain (not "*")
- [ ] Database connection uses SSL
- [ ] Firewall (UFW) is enabled
- [ ] Services run as www-data (not root)

## Additional Resources

- **Full Deployment Guide**: `docs/deployment.md`
- **Telegram Standards**: `docs/telegram-standards.md`
- **Main README**: `README.md`

## Support

For detailed deployment instructions and troubleshooting, see `docs/deployment.md`.
