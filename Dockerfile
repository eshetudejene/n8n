FROM n8nio/n8n:latest

USER root

# Create necessary directories
RUN mkdir -p /home/node/.n8n/nodes
RUN mkdir -p /opt/render/project/src/custom-extensions
RUN mkdir -p /home/node/.n8n/.n8n

# n8n base image is now Debian-based, no additional packages needed

# Skip community nodes installation to reduce memory footprint for Render free tier (512MB)
WORKDIR /home/node/.n8n

# Create startup script optimized for Render free tier (512MB RAM)
RUN echo '#!/bin/sh' > /usr/local/bin/start-n8n.sh && \
    echo 'echo "Starting n8n on port 5678 with 256MB heap limit..."' >> /usr/local/bin/start-n8n.sh && \
    echo 'node --max-old-space-size=256 /usr/local/lib/node_modules/n8n/bin/n8n start' >> /usr/local/bin/start-n8n.sh && \
    chmod +x /usr/local/bin/start-n8n.sh

# Set permissions - CRITICAL: ensure node user has full access to all required directories
RUN chown -R node:node /home/node && \
    chmod -R 755 /home/node && \
    chmod 700 /home/node/.n8n/.n8n && \
    chown node:node /usr/local/bin/start-n8n.sh

# Switch back to node user
USER node
WORKDIR /home/node

# Environment variables optimized for low memory (512MB Render free tier)
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_LOG_LEVEL=warn
ENV PORT=5678
ENV N8N_PORT=5678
# Memory optimization settings
ENV EXECUTIONS_DATA_SAVE_ON_ERROR=none
ENV EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
ENV EXECUTIONS_DATA_PRUNE=true
ENV EXECUTIONS_DATA_MAX_AGE=168
ENV N8N_PAYLOAD_SIZE_MAX=16777216
ENV N8N_DEFAULT_BINARY_DATA_MODE=filesystem