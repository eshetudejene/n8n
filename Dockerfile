FROM n8nio/n8n:latest

USER root

# Create necessary directories
RUN mkdir -p /home/node/.n8n/nodes
RUN mkdir -p /opt/render/project/src/custom-extensions
RUN mkdir -p /home/node/.n8n/.n8n

# n8n base image is now Debian-based, no additional packages needed

# Install community nodes during build - combined into single layer to reduce memory usage
RUN mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-document-generator && \
    mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-imap && \
    cd /opt/render/project/src/custom-extensions/n8n-nodes-document-generator && \
    npm init -y && \
    npm install n8n-nodes-document-generator@1.0.10 && \
    cd /opt/render/project/src/custom-extensions/n8n-nodes-imap && \
    npm init -y && \
    npm install n8n-nodes-imap@2.5.0 && \
    rm -rf /root/.npm /tmp/npm-*

# Create n8n.json configuration - REMOVED chatwoot
WORKDIR /home/node/.n8n
RUN echo '{"nodes":{"include":["n8n-nodes-document-generator","n8n-nodes-imap"]}}' > n8n.json

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