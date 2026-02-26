#!/bin/bash

echo "Setting up dnsmasq for wildcard .local DNS resolution"
echo "======================================================="
echo ""
echo "This script will:"
echo "  1. Configure dnsmasq to resolve *.local to 127.0.0.1"
echo "  2. Start dnsmasq service"
echo "  3. Configure macOS to use dnsmasq for .local domains"
echo ""
echo "You will be prompted for your password (sudo required)"
echo ""
read -p "Press Enter to continue..."

# Configure dnsmasq
echo ""
echo "Step 1: Configuring dnsmasq..."
echo "address=/.local/127.0.0.1" | sudo tee -a /opt/homebrew/etc/dnsmasq.conf

# Start dnsmasq service
echo ""
echo "Step 2: Starting dnsmasq service..."
sudo brew services start dnsmasq

# Wait for service to start
sleep 2

# Create resolver directory if it doesn't exist
echo ""
echo "Step 3: Configuring macOS resolver..."
sudo mkdir -p /etc/resolver

# Create resolver for .local domains
echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/local

echo ""
echo "✅ Setup complete!"
echo ""
echo "Testing DNS resolution..."
echo ""

# Test DNS resolution
if ping -c 1 -W 1 test.local >/dev/null 2>&1; then
    echo "✅ test.local resolves to 127.0.0.1"
else
    echo "⚠️  DNS test failed - you may need to restart your network or computer"
fi

echo ""
echo "You can now use any *.local domain without editing /etc/hosts!"
echo "Examples:"
echo "  - myapp.local"
echo "  - api.local"
echo "  - anything.local"
echo ""
echo "All will automatically resolve to 127.0.0.1 (localhost)"
