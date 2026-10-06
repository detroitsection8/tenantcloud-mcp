#!/usr/bin/env bash
# One-step setup of the TenantCloud connector (tc-mcp) for Claude Code on a Mac.
# Run from inside this repo:   bash setup.sh
# Safe to re-run: it rebuilds and re-registers. Run it again after pulling updates.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="$REPO_DIR/packages/mcp/dist/cli.js"

say()  { printf '\n\033[1m%s\033[0m\n' "$1"; }
fail() { printf '\n\033[31mStopped: %s\033[0m\n' "$1" >&2; exit 1; }

say "1/4  Checking this computer has what it needs..."
command -v node >/dev/null 2>&1 || fail "Node.js isn't installed. Download the LTS version from https://nodejs.org, install it, then run this again."
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 20 ] || fail "Node.js is too old (version $NODE_MAJOR). Install the LTS version from https://nodejs.org, then run this again."
command -v claude >/dev/null 2>&1 || fail "Claude Code isn't installed (the 'claude' command wasn't found). Install it from https://claude.com/claude-code, then run this again."
echo "OK: Node $(node -v), Claude Code found."

say "2/4  Downloading supporting software and building (1-2 minutes)..."
cd "$REPO_DIR"
# Private cache folder avoids a common permissions problem with npm's shared cache.
npm ci --cache "${TMPDIR:-/tmp}/tc-mcp-npm-cache" --no-audit --no-fund
npm run build
[ -f "$CLI" ] || fail "The build finished but $CLI is missing."

say "3/4  Connecting it to Claude Code (for all projects)..."
claude mcp remove tc-mcp -s user >/dev/null 2>&1 || true
claude mcp remove tc-mcp -s local >/dev/null 2>&1 || true
# The trailing "mcp" is required; without it the tool prints help and exits.
claude mcp add --scope user --transport stdio tc-mcp -- node "$CLI" mcp

say "4/4  Sign in to TenantCloud with YOUR OWN login (a window will open)..."
node "$CLI" login

say "Done. Fully quit Claude Code (Cmd+Q), reopen it, and ask: \"How many properties do we have in TenantCloud?\""
