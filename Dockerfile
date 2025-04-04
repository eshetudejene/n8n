FROM n8nio/n8n:latest

USER root

# Create necessary directories
RUN mkdir -p /home/node/.n8n/nodes
RUN mkdir -p /opt/render/project/src/custom-extensions

# For Puppeteer, install Chrome dependencies (using apk for Alpine Linux)
RUN apk update && apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
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

# Install n8n-nodes-mcp
RUN mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-mcp
WORKDIR /opt/render/project/src/custom-extensions/n8n-nodes-mcp
RUN npm init -y
RUN npm install n8n-nodes-mcp@0.1.14

# Create n8n.json configuration
WORKDIR /home/node/.n8n
RUN echo '{"nodes":{"include":["n8n-nodes-document-generator","n8n-nodes-chatwoot","n8n-nodes-imap","n8n-nodes-puppeteer","n8n-nodes-mcp"]}}' > n8n.json

# Set permissions
RUN chown -R node:node /home/node/.n8n
RUN chown -R node:node /opt/render/project/src/custom-extensions

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

# Expose the port
EXPOSE 5678

# Use the default entrypoint and command from the base image
# This is important - we're not overriding the ENTRYPOINT or CMD
