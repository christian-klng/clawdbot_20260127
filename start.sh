#!/bin/bash
set -e

mkdir -p /data/.clawdbot
mkdir -p /data/workspace

# Only create config if it doesn't exist yet (preserve existing config across redeploys)
if [ -f "/data/.clawdbot/clawdbot.json" ]; then
  echo "Existing config found, preserving it."
else
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

echo "Current config:"
cat /data/.clawdbot/clawdbot.json

exec clawdbot gateway --bind lan --port 8080
