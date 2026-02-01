#!/bin/bash
# TMA Studio Deployment Script
# Run this script on your VDS to deploy the application

set -e  # Exit on error

echo "🚀 TMA Studio Deployment Script"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Variables
APP_DIR="/opt/tma-studio"
WEB_DIR="/var/www/tma-studio"
REPO_URL="${REPO_URL:-https://github.com/yourusername/tma-studio.git}"

echo "📋 Configuration:"
echo "  App directory: $APP_DIR"
echo "  Web directory: $WEB_DIR"
echo "  Repository: $REPO_URL"
echo ""

# Step 1: Update system
echo "📦 Step 1: Updating system packages..."
apt update && apt upgrade -y

# Step 2: Install dependencies
echo "📦 Step 2: Installing dependencies..."
apt install -y nginx python3.12 python3.12-venv python3-pip postgresql-client git certbot python3-certbot-nginx

# Install Node.js 20
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ npm version: $(npm --version)"
echo "✅ Python version: $(python3.12 --version)"

# Step 3: Clone repository
echo "📥 Step 3: Cloning repository..."
if [ -d "$APP_DIR" ]; then
    echo "⚠️  Directory $APP_DIR already exists. Pulling latest changes..."
    cd $APP_DIR
    git pull origin main
else
    git clone $REPO_URL $APP_DIR
    cd $APP_DIR
fi

# Step 4: Set up Python virtual environment
echo "🐍 Step 4: Setting up Python virtual environment..."
python3.12 -m venv venv
source venv/bin/activate

echo "📦 Installing API dependencies..."
pip install -r apps/api/requirements.txt

echo "📦 Installing bot dependencies..."
pip install -r apps/bot/requirements.txt

deactivate

# Step 5: Build frontend
echo "🌐 Step 5: Building frontend..."
cd $APP_DIR/apps/web
npm install
npm run build

# Step 6: Deploy frontend
echo "📂 Step 6: Deploying frontend..."
mkdir -p $WEB_DIR
rm -rf $WEB_DIR/*
cp -r dist/* $WEB_DIR/
chown -R www-data:www-data $WEB_DIR

# Step 7: Configure Nginx
echo "⚙️  Step 7: Configuring Nginx..."
cp $APP_DIR/deploy/nginx/tma-studio-app.conf /etc/nginx/sites-available/tma-studio-app
cp $APP_DIR/deploy/nginx/tma-studio-api.conf /etc/nginx/sites-available/tma-studio-api

ln -sf /etc/nginx/sites-available/tma-studio-app /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/tma-studio-api /etc/nginx/sites-enabled/

# Test Nginx configuration
nginx -t

# Step 8: Configure systemd services
echo "⚙️  Step 8: Configuring systemd services..."
cp $APP_DIR/deploy/systemd/tma-studio-api.service /etc/systemd/system/
cp $APP_DIR/deploy/systemd/tma-studio-bot.service /etc/systemd/system/

systemctl daemon-reload

# Step 9: Check environment files
echo "🔐 Step 9: Checking environment files..."
if [ ! -f "$APP_DIR/apps/api/.env" ]; then
    echo "⚠️  WARNING: $APP_DIR/apps/api/.env not found!"
    echo "   Please create it from .env.example and configure all variables"
fi

if [ ! -f "$APP_DIR/apps/bot/.env" ]; then
    echo "⚠️  WARNING: $APP_DIR/apps/bot/.env not found!"
    echo "   Please create it from .env.example and configure all variables"
fi

# Set proper permissions
chmod 600 $APP_DIR/apps/api/.env 2>/dev/null || true
chmod 600 $APP_DIR/apps/bot/.env 2>/dev/null || true
chown www-data:www-data $APP_DIR/apps/api/.env 2>/dev/null || true
chown www-data:www-data $APP_DIR/apps/bot/.env 2>/dev/null || true

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Configure environment files:"
echo "     - Edit $APP_DIR/apps/api/.env"
echo "     - Edit $APP_DIR/apps/bot/.env"
echo ""
echo "  2. Update Nginx configs with your domain:"
echo "     - Edit /etc/nginx/sites-available/tma-studio-app"
echo "     - Edit /etc/nginx/sites-available/tma-studio-api"
echo "     - Replace 'yourdomain.com' with your actual domain"
echo ""
echo "  3. Reload Nginx:"
echo "     systemctl reload nginx"
echo ""
echo "  4. Apply database migrations:"
echo "     export DATABASE_URL='your-database-url'"
echo "     psql \$DATABASE_URL -f $APP_DIR/apps/api/migrations/001_initial.sql"
echo ""
echo "  5. Configure SSL with Let's Encrypt:"
echo "     certbot --nginx -d app.yourdomain.com -d api.yourdomain.com"
echo ""
echo "  6. Start services:"
echo "     systemctl enable tma-studio-api.service"
echo "     systemctl enable tma-studio-bot.service"
echo "     systemctl start tma-studio-api.service"
echo "     systemctl start tma-studio-bot.service"
echo ""
echo "  7. Check service status:"
echo "     systemctl status tma-studio-api.service"
echo "     systemctl status tma-studio-bot.service"
echo ""
echo "  8. Test deployment:"
echo "     curl https://api.yourdomain.com/api/health"
echo ""
