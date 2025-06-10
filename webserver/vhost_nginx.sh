#!/bin/bash

# Nginx Virtual Host Creator with Interactive Prompts
# Creates and enables VHost without reloading Nginx

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[1;31mError: This script must be run as root (use sudo)\033[0m" >&2
    exit 1
fi

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to validate domain format
validate_domain() {
    local domain_regex='^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
    [[ "$1" =~ $domain_regex ]]
}

# Function to validate port number
validate_port() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}

# Get domain name
while true; do
    read -p "Enter domain name (e.g., example.com): " DOMAIN
    if validate_domain "$DOMAIN"; then
        break
    else
        echo -e "${RED}Error: Invalid domain format. Please try again.${NC}"
    fi
done

# Get port number
while true; do
    read -p "Enter application port (1-65535): " APP_PORT
    if validate_port "$APP_PORT"; then
        break
    else
        echo -e "${RED}Error: Port must be between 1 and 65535.${NC}"
    fi
done

# Nginx paths
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
CONFIG_FILE="$NGINX_AVAILABLE/$DOMAIN"

# Check if config already exists
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Warning: Configuration for $DOMAIN already exists at:${NC}"
    echo -e "${YELLOW}$CONFIG_FILE${NC}"
    read -p "Overwrite? (y/n): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Aborted. No changes were made.${NC}"
        exit 1
    fi
fi

# Create the Nginx configuration
cat > "$CONFIG_FILE" <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass http://localhost:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    access_log /var/log/nginx/${DOMAIN}_access.log;
    error_log /var/log/nginx/${DOMAIN}_error.log;
}
EOF

# Create symlink if it doesn't exist
if [ ! -L "$NGINX_ENABLED/$DOMAIN" ]; then
    ln -s "$CONFIG_FILE" "$NGINX_ENABLED/"
fi

echo -e "\n${GREEN}Success! Virtual host configuration created:${NC}"
echo -e "${GREEN}$CONFIG_FILE${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Test Nginx configuration:"
echo -e "   ${YELLOW}sudo nginx -t${NC}"
echo "2. When ready, reload Nginx:"
echo -e "   ${YELLOW}sudo systemctl reload nginx${NC}"
echo "3. Set up DNS records for $DOMAIN to point to this server"

exit 0