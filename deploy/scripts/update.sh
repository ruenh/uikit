#!/bin/bash
# TMA Studio Update Script
# Run this script to update the application after deployment

set -e  # Exit on error

echo "🔄 TMA Studio Update Script"
echo "==========================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

APP_DIR="/opt/tma-studio"
WEB_DIR="/var/www/tma-studio"

# Step 1: Pull latest code
echo "📥 Step 1: Pulling latest code..."
cd $APP_DIR
git pull origin main

# Step 2: Update backend dependencies
echo "🐍 Step 2: Updating backend dependencies..."
source venv/bin/activate
pip install -r apps/api/requirements.txt
pip install -r apps/bot/requirements.txt
deactivate

# Step 3: Rebuild frontend
echo "🌐 Step 3: Rebuilding frontend..."
cd $APP_DIR/apps/web
npm install
npm run build

# Step 4: Deploy frontend
echo "📂 Step 4: Deploying frontend..."
rm -rf $WEB_DIR/*
cp -r dist/* $WEB_DIR/
chown -R www-data:www-data $WEB_DIR

# Step 5: Apply new migrations (if any)
echo "🗄️  Step 5: Checking for new migrations..."
if [ -f "$APP_DIR/apps/api/migrations/002_*.sql" ]; then
    echo "⚠️  New migrations found. Please apply them manually:"
    echo "   export DATABASE_URL='your-database-url'"
    echo "   psql \$DATABASE_URL -f $APP_DIR/apps/api/migrations/002_*.sql"
fi

# Step 6: Restart services
echo "🔄 Step 6: Restarting services..."
systemctl restart tma-studio-api.service
systemctl restart tma-studio-bot.service

# Step 7: Check service status
echo "✅ Step 7: Checking service status..."
systemctl status tma-studio-api.service --no-pager
systemctl status tma-studio-bot.service --no-pager

echo ""
echo "✅ Update complete!"
echo ""
echo "📋 Verify deployment:"
echo "  curl https://api.yourdomain.com/api/health"
echo ""
