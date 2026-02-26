#!/bin/bash

# Caddy management script
# Adds localhost entries to Caddyfile with proper TLS configuration

CADDYFILE="/opt/homebrew/etc/caddy/Caddyfile"

caddy-add() {
    local domain=""
    local port=""
    local type="proxy"
    local path=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                domain="$2"
                shift 2
                ;;
            -p|--port)
                port="$2"
                shift 2
                ;;
            -t|--type)
                type="$2"
                shift 2
                ;;
            --path)
                path="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: caddy-add [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -d, --domain DOMAIN    Domain name (e.g., myapp.test)"
                echo "  -p, --port PORT        Port number for reverse proxy"
                echo "  -t, --type TYPE        Type: 'proxy' (default) or 'static'"
                echo "  --path PATH            Path for static site (required if type=static)"
                echo "  -h, --help             Show this help message"
                echo ""
                echo "Examples:"
                echo "  caddy-add -d myapp.test -p 3000"
                echo "  caddy-add -d blog.test -t static --path ~/Sites/blog"
                return 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use -h or --help for usage information"
                return 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$domain" ]]; then
        echo "Error: Domain is required (-d or --domain)"
        echo "Use -h or --help for usage information"
        return 1
    fi

    # Ensure domain ends with .test for safety
    if [[ ! "$domain" =~ \.test$ ]]; then
        echo "Warning: Domain '$domain' doesn't end with .test"
        read -p "Continue anyway? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted"
            return 1
        fi
    fi

    # Check if domain already exists in Caddyfile
    if grep -q "^${domain}" "$CADDYFILE" 2>/dev/null; then
        echo "Error: Domain '$domain' already exists in Caddyfile"
        return 1
    fi

    # Build the Caddyfile entry
    local entry=""

    if [[ "$type" == "proxy" ]]; then
        if [[ -z "$port" ]]; then
            echo "Error: Port is required for reverse proxy (-p or --port)"
            return 1
        fi
        entry="# ${domain} - reverse proxy to localhost:${port}\n${domain} {\n\ttls internal\n\treverse_proxy localhost:${port}\n}\n"
    elif [[ "$type" == "static" ]]; then
        if [[ -z "$path" ]]; then
            echo "Error: Path is required for static site (--path)"
            return 1
        fi
        # Expand tilde to home directory
        path="${path/#\~/$HOME}"
        if [[ ! -d "$path" ]]; then
            echo "Warning: Path '$path' does not exist"
            read -p "Add anyway? (y/N): " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo "Aborted"
                return 1
            fi
        fi
        entry="# ${domain} - static site\n${domain} {\n\ttls internal\n\troot * ${path}\n\tfile_server\n}\n"
    else
        echo "Error: Invalid type '$type'. Use 'proxy' or 'static'"
        return 1
    fi

    # Add entry to Caddyfile
    echo -e "\n${entry}" >> "$CADDYFILE"

    # Add to /etc/hosts for .local domains (bypasses mDNS)
    if [[ "$domain" =~ \.local$ ]]; then
        if ! grep -q "127.0.0.1.*${domain}" /etc/hosts 2>/dev/null; then
            echo ""
            echo "Adding $domain to /etc/hosts (required for .local domains)..."
            echo "127.0.0.1 ${domain}" | sudo tee -a /etc/hosts >/dev/null
            echo "✓ Added to /etc/hosts"
        fi
    fi

    echo "Added $domain to Caddyfile"
    echo ""
    echo "Entry added:"
    echo -e "$entry"
    echo ""
    echo "Reloading Caddy configuration..."

    # Reload Caddy
    if command -v caddy >/dev/null 2>&1; then
        caddy reload --config "$CADDYFILE" 2>&1
        if [[ $? -eq 0 ]]; then
            echo "Caddy reloaded successfully!"
            echo "Visit: https://$domain"
        else
            echo "Warning: Caddy reload failed. Try: brew services restart caddy"
        fi
    else
        echo "Note: 'caddy' command not found. Restart service with:"
        echo "  brew services restart caddy"
    fi
}

caddy-list() {
    if [[ ! -f "$CADDYFILE" ]]; then
        echo "Error: Caddyfile not found at $CADDYFILE"
        return 1
    fi

    echo "Current Caddy domains:"
    echo ""
    grep -E "^[a-zA-Z0-9\.\-]+\.(test|local|localhost)" "$CADDYFILE" | sed 's/ {$//' | sort
}

caddy-remove() {
    local domain="$1"

    if [[ -z "$domain" ]]; then
        echo "Usage: caddy-remove DOMAIN"
        echo "Example: caddy-remove myapp.test"
        return 1
    fi

    if [[ ! -f "$CADDYFILE" ]]; then
        echo "Error: Caddyfile not found at $CADDYFILE"
        return 1
    fi

    # Check if domain exists
    if ! grep -q "^${domain}" "$CADDYFILE"; then
        echo "Error: Domain '$domain' not found in Caddyfile"
        return 1
    fi

    # Create backup
    cp "$CADDYFILE" "${CADDYFILE}.backup"
    echo "Backup created: ${CADDYFILE}.backup"

    # Remove the entry (comment line + domain block)
    # This removes from the comment line before the domain up to and including the closing brace
    sed -i '' "/^# .*${domain}/,/^}/d" "$CADDYFILE"

    # Remove from /etc/hosts if present
    if grep -q "127.0.0.1.*${domain}" /etc/hosts 2>/dev/null; then
        echo "Removing $domain from /etc/hosts..."
        sudo sed -i '' "/127.0.0.1.*${domain}/d" /etc/hosts
        echo "✓ Removed from /etc/hosts"
    fi

    echo "Removed $domain from Caddyfile"
    echo "Reloading Caddy..."

    if command -v caddy >/dev/null 2>&1; then
        caddy reload --config "$CADDYFILE" 2>&1
        if [[ $? -eq 0 ]]; then
            echo "Caddy reloaded successfully!"
        else
            echo "Warning: Caddy reload failed. Try: brew services restart caddy"
        fi
    else
        echo "Note: Restart service with: brew services restart caddy"
    fi
}

caddy-edit() {
    if [[ ! -f "$CADDYFILE" ]]; then
        echo "Error: Caddyfile not found at $CADDYFILE"
        return 1
    fi

    eval "${EDITOR:-nano} \"\$CADDYFILE\""
}

caddy-reload() {
    if command -v caddy >/dev/null 2>&1; then
        echo "Reloading Caddy configuration..."
        caddy reload --config "$CADDYFILE" 2>&1
        if [[ $? -eq 0 ]]; then
            echo "Caddy reloaded successfully!"
        else
            echo "Reload failed. Try: brew services restart caddy"
        fi
    else
        echo "Restarting Caddy service..."
        brew services restart caddy
    fi
}

caddy-status() {
    echo "Caddy service status:"
    brew services info caddy
    echo ""
    echo "Current domains:"
    caddy-list
}
