# Deployment Guide for givexy.ru

## Prerequisites

1. **DNS Configuration** - Create these A-records:
   - `givexy.ru` → Your VDS IP
   - `api.givexy.ru` → Your VDS IP

2. **Server Requirements**:
   - Ubuntu 24.04 (or 22.04)
   - Root or sudo access
   - Minimum 2GB RAM
   - 20GB disk space

3. **Required Information**:
   - Telegram Bot Token (from @BotFather)
   - PostgreSQL Database URL (Supabase recommended)

## Quick Deployment

### Option 1: Automated Smart Deployment (Recommended)

```bash
# SSH to your server
ssh root@your-server-ip

# Download and run smart deployment script
curl -fsSL https://raw.githubusercontent.com/ruenh/uikit/main/deploy/scripts/smart-deploy.sh | bash
```

The script will:
- ✅ Automatically find free ports (if 8000 is occupied)
- ✅ Install all dependencies
- ✅ Configure Nginx with givexy.ru
- ✅ Set up SSL certificates
- ✅ Create systemd services
- ✅ Start and verify deployment

### Option 2: Manual Deployment

```bash
# 1. SSH to server
ssh root@your-server-ip

# 2. Check available ports
cd /tmp
wget https://raw.githubusercontent.com/ruenh/uikit/main/deploy/scripts/check-ports.sh
chmod +x check-ports.sh
./check-ports.sh

# If port 8000 is occupied, find a free one:
wget https://raw.githubusercontent.com/ruenh/uikit/main/deploy/scripts/find-free-port.sh
chmod +x find-free-port.sh
./find-free-port.sh 8000 8100

# 3. Clone repository
git clone https://github.com/ruenh/uikit.git /opt/tma-studio
cd /opt/tma-studio

# 4. Follow manual deployment guide
cat docs/deployment.md
```

## Port Configuration

If port 8000 is already in use, the smart deployment script will automatically find a free port.

To manually change the API port:

1. **Edit systemd service** (`/etc/systemd/system/tma-studio-api.service`):
   ```ini
   ExecStart=/opt/tma-studio/apps/api/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8001
   ```

2. **Edit Nginx config** (`/etc/nginx/sites-available/api.givexy.ru`):
   ```nginx
   proxy_pass http://127.0.0.1:8001;
   ```

3. **Reload services**:
   ```bash
   systemctl daemon-reload
   systemctl restart tma-studio-api.service
   systemctl reload nginx
   ```

## Post-Deployment Verification

### 1. Check Services Status

```bash
# Check API service
systemctl status tma-studio-api.service

# Check Bot service
systemctl status tma-studio-bot.service

# Check Nginx
systemctl status nginx
```

### 2. Test API Health

```bash
# Local test
curl http://localhost:8000/api/health

# Public test (after SSL)
curl https://api.givexy.ru/api/health
```

Expected response:
```json
{"status":"healthy","database":"connected"}
```

### 3. Test Frontend

Open in browser: https://givexy.ru

Should see the TMA Studio home page.

### 4. Test Bot

1. Open your Telegram bot
2. Send `/start` command
3. Click "Open TMA Studio" button
4. Mini App should load

## Troubleshooting

### API Service Won't Start

```bash
# View logs
journalctl -u tma-studio-api.service -n 100

# Common issues:
# - Port already in use → Change port in systemd service
# - Database connection failed → Check DATABASE_URL in .env
# - Missing dependencies → Reinstall: pip install -r requirements.txt
```

### Bot Service Won't Start

```bash
# View logs
journalctl -u tma-studio-bot.service -n 100

# Common issues:
# - Invalid BOT_TOKEN → Check token in .env
# - Network issues → Check firewall settings
```

### SSL Certificate Issues

```bash
# Manually obtain certificates
certbot --nginx -d givexy.ru -d api.givexy.ru

# Check certificate status
certbot certificates

# Renew certificates
certbot renew
```

### Port Conflicts

```bash
# Find what's using a port
ss -tulnp | grep :8000

# Kill process using port (if safe)
kill -9 <PID>

# Or use a different port (see Port Configuration above)
```

## Maintenance

### Update Application

```bash
cd /opt/tma-studio
git pull
cd apps/web && npm install && npm run build
systemctl restart tma-studio-api.service
systemctl restart tma-studio-bot.service
```

### View Logs

```bash
# API logs (live)
journalctl -u tma-studio-api.service -f

# Bot logs (live)
journalctl -u tma-studio-bot.service -f

# Nginx access logs
tail -f /var/log/nginx/access.log

# Nginx error logs
tail -f /var/log/nginx/error.log
```

### Restart Services

```bash
# Restart API
systemctl restart tma-studio-api.service

# Restart Bot
systemctl restart tma-studio-bot.service

# Reload Nginx (without downtime)
systemctl reload nginx
```

## Security Checklist

- [ ] DNS records point to correct IP
- [ ] SSL certificates obtained and valid
- [ ] Firewall configured (ports 80, 443 open)
- [ ] `.env` files have correct values
- [ ] Database migrations applied
- [ ] Services running as `www-data` (not root)
- [ ] File permissions correct (644 for files, 755 for directories)
- [ ] Bot token kept secret
- [ ] JWT_SECRET is strong (32+ characters)

## Support

For issues:
1. Check logs (see Maintenance section)
2. Review [main deployment guide](../docs/deployment.md)
3. Open issue on GitHub: https://github.com/ruenh/uikit/issues
