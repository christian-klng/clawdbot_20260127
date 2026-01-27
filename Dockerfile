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

CMD ["clawdbot", "gateway", "--bind", "0.0.0.0", "--port", "8080", "--allow-unconfigured"]
