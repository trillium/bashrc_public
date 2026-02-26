# Caddy Management Commands

I have a Caddy web server configured on macOS with custom shell commands for managing local development domains.

## Available Commands

**caddy-add** - Add a new domain to Caddyfile
- For reverse proxy: `caddy-add -d DOMAIN.test -p PORT`
- For static site: `caddy-add -d DOMAIN.test -t static --path PATH`
- Examples:
  - `caddy-add -d myapp.test -p 3000`
  - `caddy-add -d blog.test -t static --path ~/Sites/blog`

**caddy-list** - List all configured domains

**caddy-remove** - Remove a domain
- Usage: `caddy-remove DOMAIN.test`

**caddy-edit** - Open Caddyfile in editor

**caddy-reload** - Reload Caddy configuration

**caddy-status** - Show Caddy service status and all domains

## Important Notes

- Caddyfile location: `/opt/homebrew/etc/caddy/Caddyfile`
- All `.test` domains automatically get `tls internal` (self-signed cert)
- Commands auto-reload Caddy after changes
- Each app needs a unique port (3000, 3001, 3002, etc.)
- Backups are created automatically when removing domains

## When Helping Me

1. Use these commands to add/remove/modify domains
2. Execute commands with the Bash tool
3. If adding multiple domains, assign different ports starting from 3000
4. Always use `.test` TLD for local development domains
