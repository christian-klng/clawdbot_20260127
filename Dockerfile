FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install clawdbot from npm (pre-built)
RUN npm install -g clawdbot@latest

# Create data directories
RUN mkdir -p /data/.clawdbot /data/workspace

ENV CLAWDBOT_STATE_DIR=/data/.clawdbot
ENV CLAWDBOT_WORKSPACE_DIR=/data/workspace
ENV PORT=8080

EXPOSE 8080

# Create startup script that writes config before starting
RUN echo '#!/bin/bash\n\
mkdir -p /data/.clawdbot\n\
cat > /data/.clawdbot/clawdbot.json << EOF\n\
{\n\
  "gateway": {\n\
    "mode": "local",\n\
    "token": "${CLAWDBOT_GATEWAY_TOKEN}"\n\
  }\n\
}\n\
EOF\n\
exec clawdbot gateway --bind lan --port 8080\n\
' > /start.sh && chmod +x /start.sh

CMD ["/bin/bash", "/start.sh"]
