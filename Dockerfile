FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g clawdbot@latest

RUN mkdir -p /data/.clawdbot /data/workspace

ENV CLAWDBOT_STATE_DIR=/data/.clawdbot
ENV CLAWDBOT_WORKSPACE_DIR=/data/workspace
ENV PORT=8080

EXPOSE 8080

RUN echo '#!/bin/bash\n\
mkdir -p /data/.clawdbot\n\
cat > /data/.clawdbot/clawdbot.json << EOF\n\
{\n\
  "gateway": {\n\
    "mode": "local",\n\
    "controlUi": {\n\
      "enabled": true,\n\
      "allowInsecureAuth": true\n\
    },\n\
    "auth": {\n\
      "mode": "token",\n\
      "token": "${CLAWDBOT_GATEWAY_TOKEN}"\n\
    }\n\
  },\n\
  "agents": {\n\
    "defaults": {\n\
      "workspace": "/data/workspace"\n\
    }\n\
  }\n\
}\n\
EOF\n\
exec clawdbot gateway --bind lan --port 8080\n\
' > /start.sh && chmod +x /start.sh

CMD ["/bin/bash", "/start.sh"]
