FROM n8nio/n8n:latest

USER root

# Install community nodes
RUN mkdir -p /home/node/.n8n/nodes
WORKDIR /home/node/.n8n

# Install community nodes
RUN npm install n8n-nodes-document-generator@1.0.10 \
    n8n-nodes-chatwoot@0.1.40 \
    n8n-nodes-imap@2.5.0 \
    n8n-nodes-puppeteer@1.4.1 \
    n8n-nodes-mcp@0.1.14

# For Puppeteer, install Chrome dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create n8n.json config file
RUN echo '{"nodes":{"include":["n8n-nodes-document-generator","n8n-nodes-chatwoot","n8n-nodes-imap","n8n-nodes-puppeteer","n8n-nodes-mcp"]}}' > /home/node/.n8n/n8n.json

# Set permissions
RUN chown -R node:node /home/node/.n8n

# Switch back to node user
USER node

# Environment variables for community nodes
ENV N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true
ENV N8N_REINSTALL_MISSING_PACKAGES=true
ENV N8N_COMMUNITY_NODES_ENABLED=true
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/nodes
ENV N8N_LOG_LEVEL=debug

# Start n8n
CMD ["n8n", "start"]
