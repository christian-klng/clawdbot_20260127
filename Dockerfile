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

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/bin/bash", "/start.sh"]
