#!/bin/bash
set -e

mkdir -p /data/.clawdbot

# Use CLAWDBOT_CONFIG env var if set, otherwise use default
if [ -n "$CLAWDBOT_CONFIG" ]; then
  echo "Using config from CLAWDBOT_CONFIG environment variable"
  echo "$CLAWDBOT_CONFIG" > /data/.clawdbot/clawdbot.json
else
  echo "Using default config"
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

echo "Config written:"
cat /data/.clawdbot/clawdbot.json

exec clawdbot gateway --bind lan --port 8080
