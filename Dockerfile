FROM n8nio/n8n:latest

USER root

# Create necessary directories
RUN mkdir -p /home/node/.n8n/nodes
RUN mkdir -p /opt/render/project/src/custom-extensions
RUN mkdir -p /home/node/.cache/puppeteer
RUN mkdir -p /home/node/.n8n/.n8n

# For Puppeteer, install Chrome dependencies (using apk for Alpine Linux)
RUN apk update && apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    netcat-openbsd \
    && rm -rf /var/cache/apk/*

# Install community nodes during build
WORKDIR /tmp
RUN npm init -y

# Install n8n-nodes-document-generator
RUN mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-document-generator
WORKDIR /opt/render/project/src/custom-extensions/n8n-nodes-document-generator
RUN npm init -y
RUN npm install n8n-nodes-document-generator@1.0.10

# Install n8n-nodes-chatwoot
RUN mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-chatwoot
WORKDIR /opt/render/project/src/custom-extensions/n8n-nodes-chatwoot
RUN npm init -y
RUN npm install n8n-nodes-chatwoot@0.1.40

# Install n8n-nodes-imap
RUN mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-imap
WORKDIR /opt/render/project/src/custom-extensions/n8n-nodes-imap
RUN npm init -y
RUN npm install n8n-nodes-imap@2.5.0

# Install n8n-nodes-puppeteer
RUN mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-puppeteer
WORKDIR /opt/render/project/src/custom-extensions/n8n-nodes-puppeteer
RUN npm init -y
RUN npm install n8n-nodes-puppeteer@1.4.1
# Install Puppeteer browser
RUN cd /opt/render/project/src/custom-extensions/n8n-nodes-puppeteer && \
    npx puppeteer browsers install chrome

# Create n8n.json configuration
WORKDIR /home/node/.n8n
RUN echo '{"nodes":{"include":["n8n-nodes-document-generator","n8n-nodes-chatwoot","n8n-nodes-imap","n8n-nodes-puppeteer"]}}' > n8n.json

# Create startup script to ensure port is properly exposed
RUN echo '#!/bin/sh' > /usr/local/bin/start-n8n.sh && \
    echo 'echo "Starting n8n on port 5678..."' >> /usr/local/bin/start-n8n.sh && \
    echo 'node --max-old-space-size=4096 /usr/local/lib/node_modules/n8n/bin/n8n start' >> /usr/local/bin/start-n8n.sh && \
    chmod +x /usr/local/bin/start-n8n.sh

# Set permissions - CRITICAL: ensure node user has full access to all required directories
RUN chown -R node:node /home/node
RUN chmod -R 755 /home/node
RUN chmod 700 /home/node/.n8n/.n8n
RUN chown -R node:node /opt/render/project/src/custom-extensions
RUN chown node:node /usr/local/bin/start-n8n.sh

# We'll let n8n create its own config file with the correct encryption key
# from the environment variable

# Switch back to node user
USER node
WORKDIR /home/node

# Environment variables for community nodes
ENV N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true
ENV N8N_REINSTALL_MISSING_PACKAGES=true
ENV N8N_COMMUNITY_NODES_ENABLED=true
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_CUSTOM_EXTENSIONS=/opt/render/project/src/custom-extensions
ENV N8N_LOG_LEVEL=debug
ENV PORT=5678
ENV N8N_PORT=5678
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
# Puppeteer browser launch arguments for better performance in containerized environments
ENV PUPPETEER_ARGS="--no-sandbox,--disable-setuid-sandbox,--disable-dev-shm-usage,--disable-accelerated-2d-canvas,--no-first-run,--no-zygote,--disable-gpu,--disable-extensions,--disable-audio-output"
# Enforce proper file permissions for n8n settings
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
# Note: N8N_ENCRYPTION_KEY should be set in Render environment variables, not here

# Exclude MCP nodes
ENV N8N_CUSTOM_EXTENSIONS_EXCLUDE=mcp,mcpClient

# Expose the port
EXPOSE 5678

# Use our custom startup script
ENTRYPOINT ["/usr/local/bin/start-n8n.sh"]
