#!/bin/bash
# Smart deployment script for givexy.ru
# Automatically detects free ports and configures the application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="givexy.ru"
API_DOMAIN="api.givexy.ru"
PROJECT_DIR="/opt/tma-studio"
DEFAULT_API_PORT=8000

echo -e "${GREEN}=== TMA Studio Smart Deployment for ${DOMAIN} ===${NC}"
echo ""

# Step 1: Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Running as root${NC}"
echo ""

# Step 2: Check required ports
echo -e "${YELLOW}=== Checking Port Availability ===${NC}"

check_port() {
    local port=$1
    if ss -tuln | grep -q ":${port} "; then
        return 1  # Port in use
    else
        return 0  # Port available
    fi
}

# Check HTTP/HTTPS (required for Nginx)
if ! check_port 80; then
    echo -e "${YELLOW}⚠️  Port 80 (HTTP) is in use${NC}"
    echo "   This is OK if Nginx is already running"
fi

if ! check_port 443; then
    echo -e "${YELLOW}⚠️  Port 443 (HTTPS) is in use${NC}"
    echo "   This is OK if Nginx is already running"
fi

# Find free port for FastAPI
API_PORT=$DEFAULT_API_PORT
echo ""
echo "Searching for free port for FastAPI (starting from $DEFAULT_API_PORT)..."

while ! check_port $API_PORT; do
    echo -e "${YELLOW}   Port $API_PORT is in use, trying next...${NC}"
    API_PORT=$((API_PORT + 1))
    
    if [ $API_PORT -gt 8100 ]; then
        echo -e "${RED}❌ No free ports found in range 8000-8100${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ Found free port for FastAPI: $API_PORT${NC}"
echo ""

# Step 3: Clone or update repository
echo -e "${YELLOW}=== Setting Up Project Files ===${NC}"

if [ -d "$PROJECT_DIR" ]; then
    echo "Project directory exists, updating..."
    cd $PROJECT_DIR
    git pull
else
    echo "Cloning repository..."
    git clone https://github.com/ruenh/uikit.git $PROJECT_DIR
    cd $PROJECT_DIR
fi

echo -e "${GREEN}✅ Project files ready${NC}"
echo ""

# Step 4: Install dependencies
echo -e "${YELLOW}=== Installing Dependencies ===${NC}"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
fi

# Check if Python 3.12 is installed
if ! command -v python3.12 &> /dev/null; then
    echo "Installing Python 3.12..."
    add-apt-repository -y ppa:deadsnakes/ppa
    apt-get update
    apt-get install -y python3.12 python3.12-venv python3.12-dev
fi

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt-get install -y nginx
fi

# Check if Certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    apt-get install -y certbot python3-certbot-nginx
fi

echo -e "${GREEN}✅ System dependencies installed${NC}"
echo ""

# Step 5: Install project dependencies
echo "Installing web dependencies..."
cd $PROJECT_DIR/apps/web
npm install

echo "Installing API dependencies..."
cd $PROJECT_DIR/apps/api
python3.12 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate

echo "Installing bot dependencies..."
cd $PROJECT_DIR/apps/bot
python3.12 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate

echo -e "${GREEN}✅ Project dependencies installed${NC}"
echo ""

# Step 6: Configure environment variables
echo -e "${YELLOW}=== Configuring Environment Variables ===${NC}"

# Prompt for required values
read -p "Enter your Telegram BOT_TOKEN: " BOT_TOKEN
read -p "Enter your DATABASE_URL: " DATABASE_URL
read -sp "Enter JWT_SECRET (or press Enter to generate): " JWT_SECRET
echo ""

if [ -z "$JWT_SECRET" ]; then
    JWT_SECRET=$(openssl rand -base64 32)
    echo "Generated JWT_SECRET: $JWT_SECRET"
fi

# Create API .env
cat > $PROJECT_DIR/apps/api/.env << EOF
# Telegram Bot Token
BOT_TOKEN=$BOT_TOKEN

# Database
DATABASE_URL=$DATABASE_URL

# JWT Configuration
JWT_SECRET=$JWT_SECRET
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# InitData Validation (10 minutes for production)
INIT_DATA_MAX_AGE_SECONDS=600

# CORS Configuration
ALLOWED_ORIGINS=["https://${DOMAIN}"]

# Cookie Settings (Production)
COOKIE_DOMAIN=.${DOMAIN}
COOKIE_SECURE=true
COOKIE_SAMESITE=none
COOKIE_MAX_AGE=86400
EOF

# Create Bot .env
cat > $PROJECT_DIR/apps/bot/.env << EOF
# Telegram Bot Token
BOT_TOKEN=$BOT_TOKEN

# Web App URL
WEB_APP_URL=https://${DOMAIN}
EOF

# Create Web .env
cat > $PROJECT_DIR/apps/web/.env << EOF
# API URL
PUBLIC_API_URL=https://${API_DOMAIN}
EOF

echo -e "${GREEN}✅ Environment variables configured${NC}"
echo ""

# Step 7: Build frontend
echo -e "${YELLOW}=== Building Frontend ===${NC}"
cd $PROJECT_DIR/apps/web
npm run build
echo -e "${GREEN}✅ Frontend built${NC}"
echo ""

# Step 8: Apply database migrations
echo -e "${YELLOW}=== Applying Database Migrations ===${NC}"
read -p "Apply database migrations now? (y/n): " apply_migrations

if [ "$apply_migrations" = "y" ]; then
    psql "$DATABASE_URL" -f $PROJECT_DIR/apps/api/migrations/001_initial.sql
    echo -e "${GREEN}✅ Database migrations applied${NC}"
else
    echo -e "${YELLOW}⚠️  Skipped migrations. Run manually:${NC}"
    echo "   psql \$DATABASE_URL -f $PROJECT_DIR/apps/api/migrations/001_initial.sql"
fi
echo ""

# Step 9: Configure Nginx
echo -e "${YELLOW}=== Configuring Nginx ===${NC}"

# Frontend config
cat > /etc/nginx/sites-available/${DOMAIN} << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};

    root ${PROJECT_DIR}/apps/web/dist;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# API config
cat > /etc/nginx/sites-available/${API_DOMAIN} << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${API_DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:${API_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable sites
ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/${API_DOMAIN} /etc/nginx/sites-enabled/

# Test Nginx config
nginx -t

# Reload Nginx
systemctl reload nginx

echo -e "${GREEN}✅ Nginx configured${NC}"
echo ""

# Step 10: Configure SSL
echo -e "${YELLOW}=== Configuring SSL Certificates ===${NC}"
read -p "Obtain SSL certificates now? (y/n): " obtain_ssl

if [ "$obtain_ssl" = "y" ]; then
    certbot --nginx -d ${DOMAIN} -d ${API_DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN}
    echo -e "${GREEN}✅ SSL certificates obtained${NC}"
else
    echo -e "${YELLOW}⚠️  Skipped SSL. Run manually:${NC}"
    echo "   certbot --nginx -d ${DOMAIN} -d ${API_DOMAIN}"
fi
echo ""

# Step 11: Configure systemd services
echo -e "${YELLOW}=== Configuring systemd Services ===${NC}"

# API service
cat > /etc/systemd/system/tma-studio-api.service << EOF
[Unit]
Description=TMA Studio FastAPI Backend
After=network.target postgresql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=${PROJECT_DIR}/apps/api
Environment="PATH=${PROJECT_DIR}/apps/api/venv/bin"
ExecStart=${PROJECT_DIR}/apps/api/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port ${API_PORT} --workers 4
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Bot service
cat > /etc/systemd/system/tma-studio-bot.service << EOF
[Unit]
Description=TMA Studio Telegram Bot
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=${PROJECT_DIR}/apps/bot
Environment="PATH=${PROJECT_DIR}/apps/bot/venv/bin"
ExecStart=${PROJECT_DIR}/apps/bot/venv/bin/python bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R www-data:www-data $PROJECT_DIR

# Reload systemd
systemctl daemon-reload

# Enable and start services
systemctl enable tma-studio-api.service
systemctl enable tma-studio-bot.service
systemctl start tma-studio-api.service
systemctl start tma-studio-bot.service

echo -e "${GREEN}✅ systemd services configured and started${NC}"
echo ""

# Step 12: Verify deployment
echo -e "${YELLOW}=== Verifying Deployment ===${NC}"

sleep 3

# Check API service
if systemctl is-active --quiet tma-studio-api.service; then
    echo -e "${GREEN}✅ API service is running${NC}"
else
    echo -e "${RED}❌ API service failed to start${NC}"
    echo "   Check logs: journalctl -u tma-studio-api.service -n 50"
fi

# Check Bot service
if systemctl is-active --quiet tma-studio-bot.service; then
    echo -e "${GREEN}✅ Bot service is running${NC}"
else
    echo -e "${RED}❌ Bot service failed to start${NC}"
    echo "   Check logs: journalctl -u tma-studio-bot.service -n 50"
fi

# Check API health
echo ""
echo "Testing API health endpoint..."
sleep 2

if curl -f -s http://localhost:${API_PORT}/api/health > /dev/null; then
    echo -e "${GREEN}✅ API health check passed${NC}"
else
    echo -e "${RED}❌ API health check failed${NC}"
    echo "   Check logs: journalctl -u tma-studio-api.service -n 50"
fi

echo ""
echo -e "${GREEN}=== Deployment Complete! ===${NC}"
echo ""
echo "Configuration Summary:"
echo "  Frontend: https://${DOMAIN}"
echo "  API: https://${API_DOMAIN}"
echo "  API Port: ${API_PORT}"
echo ""
echo "Next Steps:"
echo "1. Test your bot: Open Telegram and send /start to your bot"
echo "2. Check logs:"
echo "   - API: journalctl -u tma-studio-api.service -f"
echo "   - Bot: journalctl -u tma-studio-bot.service -f"
echo "3. Monitor services:"
echo "   - systemctl status tma-studio-api.service"
echo "   - systemctl status tma-studio-bot.service"
echo ""
echo "Troubleshooting:"
echo "  - View API logs: journalctl -u tma-studio-api.service -n 100"
echo "  - View Bot logs: journalctl -u tma-studio-bot.service -n 100"
echo "  - Restart API: systemctl restart tma-studio-api.service"
echo "  - Restart Bot: systemctl restart tma-studio-bot.service"
echo ""
