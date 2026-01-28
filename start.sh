#!/bin/bash
set -e

echo "=========================================="
echo "CLAWDBOT STARTUP DEBUG"
echo "=========================================="
echo "Date: $(date)"
echo ""

# Debug: Show all relevant environment variables
echo "=== Environment Variables ==="
echo "CLAWDBOT_STATE_DIR: ${CLAWDBOT_STATE_DIR:-'(not set)'}"
echo "CLAWDBOT_WORKSPACE_DIR: ${CLAWDBOT_WORKSPACE_DIR:-'(not set)'}"
echo "HOME: ${HOME:-'(not set)'}"
echo "USER: $(whoami)"
echo "UID: $(id -u)"
echo "GID: $(id -g)"
echo ""

# Debug: Show mount points
echo "=== Mount Points ==="
mount | grep -E "^/dev|tmpfs" || echo "(no relevant mounts found)"
echo ""

# Debug: Check /data directory
echo "=== /data Directory Status ==="
if [ -d "/data" ]; then
  echo "/data exists"
  ls -la /data/
  echo ""
  
  # Check if it's a mount point
  if mountpoint -q /data 2>/dev/null; then
    echo "/data IS a mount point (volume is attached)"
  else
    echo "/data is NOT a mount point (NO VOLUME ATTACHED!)"
  fi
else
  echo "/data does NOT exist!"
fi
echo ""

# Create directories
echo "=== Creating Directories ==="
mkdir -p /data/.clawdbot
mkdir -p /data/workspace
echo "Created /data/.clawdbot and /data/workspace"
echo ""

# Debug: Show what's in /data/.clawdbot BEFORE any changes
echo "=== Contents of /data/.clawdbot (BEFORE) ==="
ls -la /data/.clawdbot/ 2>/dev/null || echo "(empty or does not exist)"
echo ""

# Check for existing config
if [ -f "/data/.clawdbot/clawdbot.json" ]; then
  echo "=== Existing config FOUND ==="
  echo "File info:"
  ls -la /data/.clawdbot/clawdbot.json
  echo ""
  echo "Content preview (first 20 lines):"
  head -20 /data/.clawdbot/clawdbot.json
  echo ""
  echo ">>> PRESERVING existing config <<<"
else
  echo "=== No existing config found, creating new one ==="
  
  # Use CLAWDBOT_CONFIG env var if set, otherwise use default
  if [ -n "$CLAWDBOT_CONFIG" ]; then
    echo "Creating config from CLAWDBOT_CONFIG environment variable"
    echo "$CLAWDBOT_CONFIG" > /data/.clawdbot/clawdbot.json
  else
    echo "Creating default config"
    cat > /data/.clawdbot/clawdbot.json << EOF
{
  "gateway": {
    "mode": "local",
    "controlUi": {
      "enabled": true,
      "allowInsecureAuth": true
    },
    "auth": {
      "mode": "token",
      "token": "${CLAWDBOT_GATEWAY_TOKEN}"
    }
  },
  "agents": {
    "defaults": {
      "workspace": "/data/workspace"
    }
  }
}
EOF
  fi
fi

# Debug: Show what's in /data/.clawdbot AFTER setup
echo ""
echo "=== Contents of /data/.clawdbot (AFTER) ==="
ls -la /data/.clawdbot/
echo ""

# Check for existing sessions/credentials (important for persistence check)
echo "=== Checking for persisted data ==="
if [ -d "/data/.clawdbot/agents" ]; then
  echo "agents/ directory exists:"
  find /data/.clawdbot/agents -type f 2>/dev/null | head -20 || echo "(no files)"
else
  echo "agents/ directory does NOT exist (no sessions yet)"
fi

if [ -d "/data/.clawdbot/credentials" ]; then
  echo "credentials/ directory exists:"
  ls -la /data/.clawdbot/credentials/
else
  echo "credentials/ directory does NOT exist (no credentials yet)"
fi
echo ""

# Write a persistence marker to test if volume survives redeploys
MARKER_FILE="/data/.clawdbot/.persistence-marker"
if [ -f "$MARKER_FILE" ]; then
  echo "=== PERSISTENCE CHECK ==="
  echo "Previous marker found! Content:"
  cat "$MARKER_FILE"
  echo ""
  echo ">>> DATA IS PERSISTING CORRECTLY <<<"
else
  echo "=== PERSISTENCE CHECK ==="
  echo "No previous marker found (first deploy or data was lost)"
fi
echo "Writing new marker..."
echo "Created: $(date)" > "$MARKER_FILE"
echo "Marker written to $MARKER_FILE"
echo ""

echo "=========================================="
echo "STARTING CLAWDBOT GATEWAY"
echo "=========================================="

exec clawdbot gateway --bind lan --port 8080
