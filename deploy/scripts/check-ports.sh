#!/bin/bash
# Script to check if required ports are available on the server

echo "=== Checking Port Availability ==="
echo ""

# Ports we need for TMA Studio
REQUIRED_PORTS=(
    "80:HTTP (Nginx)"
    "443:HTTPS (Nginx)"
    "8000:FastAPI Backend"
)

# Check if port is in use
check_port() {
    local port=$1
    local description=$2
    
    if ss -tuln | grep -q ":${port} "; then
        echo "❌ Port ${port} (${description}) - IN USE"
        echo "   Process using port:"
        ss -tulnp | grep ":${port} " | head -1
        return 1
    else
        echo "✅ Port ${port} (${description}) - AVAILABLE"
        return 0
    fi
}

# Check all required ports
all_available=true
for port_info in "${REQUIRED_PORTS[@]}"; do
    port="${port_info%%:*}"
    description="${port_info#*:}"
    
    if ! check_port "$port" "$description"; then
        all_available=false
    fi
    echo ""
done

# Summary
echo "==================================="
if [ "$all_available" = true ]; then
    echo "✅ All required ports are available!"
    echo "You can proceed with deployment."
else
    echo "⚠️  Some ports are in use."
    echo ""
    echo "Options:"
    echo "1. Stop services using these ports"
    echo "2. Change TMA Studio to use different ports"
    echo ""
    echo "To change FastAPI port, edit:"
    echo "  - deploy/systemd/tma-studio-api.service (--port flag)"
    echo "  - apps/web/.env (PUBLIC_API_URL)"
    echo ""
    echo "Suggested alternative ports:"
    echo "  - FastAPI: 8001, 8002, 8080, 9000"
fi

echo ""
echo "=== Current Port Usage ==="
echo "All listening ports:"
ss -tuln | grep LISTEN | awk '{print $5}' | sed 's/.*://' | sort -n | uniq
