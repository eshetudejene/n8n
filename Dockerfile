FROM n8nio/n8n:latest

USER root

# Create necessary directories
RUN mkdir -p /home/node/.n8n/nodes
RUN mkdir -p /opt/render/project/src/custom-extensions

# For Puppeteer, install Chrome dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Copy custom startup script
COPY custom-startup.sh /home/node/custom-startup.sh
RUN chmod +x /home/node/custom-startup.sh
RUN chown node:node /home/node/custom-startup.sh

# Set permissions
RUN chown -R node:node /home/node/.n8n
RUN chown -R node:node /opt/render/project/src/custom-extensions

# Switch back to node user
USER node

# Environment variables for community nodes
ENV N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true
ENV N8N_REINSTALL_MISSING_PACKAGES=true
ENV N8N_COMMUNITY_NODES_ENABLED=true
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_CUSTOM_EXTENSIONS=/opt/render/project/src/custom-extensions
ENV N8N_LOG_LEVEL=debug

# Use custom startup script
ENTRYPOINT ["/home/node/custom-startup.sh"]
