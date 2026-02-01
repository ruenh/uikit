#!/bin/bash
# Find a free port in the specified range

START_PORT=${1:-8000}
END_PORT=${2:-8100}

echo "Searching for free port between $START_PORT and $END_PORT..."
echo ""

for port in $(seq $START_PORT $END_PORT); do
    if ! ss -tuln | grep -q ":${port} "; then
        echo "✅ Found free port: $port"
        echo ""
        echo "To use this port for FastAPI:"
        echo "1. Edit deploy/systemd/tma-studio-api.service"
        echo "   Change: --port $port"
        echo ""
        echo "2. Edit apps/web/.env"
        echo "   Change: PUBLIC_API_URL=https://api.givexy.ru"
        echo "   (Nginx will proxy to localhost:$port)"
        echo ""
        echo "3. Edit deploy/nginx/tma-studio-api.conf"
        echo "   Change: proxy_pass http://127.0.0.1:$port;"
        exit 0
    fi
done

echo "❌ No free ports found in range $START_PORT-$END_PORT"
exit 1
