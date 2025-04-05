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

# Create a simple startup script directly in the Dockerfile
RUN echo '#!/bin/bash\n\
echo "Starting n8n with community nodes..."\n\
\n\
# Create necessary directories\n\
mkdir -p /opt/render/project/src/custom-extensions\n\
\n\
# Install community nodes\n\
echo "Installing community nodes..."\n\
mkdir -p /tmp/n8n-nodes\n\
cd /tmp/n8n-nodes\n\
\n\
# Initialize npm and install nodes\n\
npm init -y\n\
\n\
# Install each node in its own directory\n\
echo "Installing n8n-nodes-document-generator..."\n\
mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-document-generator\n\
cd /opt/render/project/src/custom-extensions/n8n-nodes-document-generator\n\
npm init -y\n\
npm install n8n-nodes-document-generator@1.0.10\n\
\n\
echo "Installing n8n-nodes-chatwoot..."\n\
mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-chatwoot\n\
cd /opt/render/project/src/custom-extensions/n8n-nodes-chatwoot\n\
npm init -y\n\
npm install n8n-nodes-chatwoot@0.1.40\n\
\n\
echo "Installing n8n-nodes-imap..."\n\
mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-imap\n\
cd /opt/render/project/src/custom-extensions/n8n-nodes-imap\n\
npm init -y\n\
npm install n8n-nodes-imap@2.5.0\n\
\n\
echo "Installing n8n-nodes-puppeteer..."\n\
mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-puppeteer\n\
cd /opt/render/project/src/custom-extensions/n8n-nodes-puppeteer\n\
npm init -y\n\
npm install n8n-nodes-puppeteer@1.4.1\n\
\n\
echo "Installing n8n-nodes-mcp..."\n\
mkdir -p /opt/render/project/src/custom-extensions/n8n-nodes-mcp\n\
cd /opt/render/project/src/custom-extensions/n8n-nodes-mcp\n\
npm init -y\n\
npm install n8n-nodes-mcp@0.1.14\n\
\n\
# Create n8n.json configuration\n\
echo "Creating n8n.json configuration..."\n\
cat > /home/node/.n8n/n8n.json << EOL\n\
{\n\
  "nodes": {\n\
    "include": [\n\
      "n8n-nodes-document-generator",\n\
      "n8n-nodes-chatwoot",\n\
      "n8n-nodes-imap",\n\
      "n8n-nodes-puppeteer",\n\
      "n8n-nodes-mcp"\n\
    ]\n\
  }\n\
}\n\
EOL\n\
\n\
# Start n8n\n\
echo "Starting n8n..."\n\
exec n8n start\n\
' > /home/node/startup.sh

# Make the script executable
RUN chmod +x /home/node/startup.sh
RUN chown node:node /home/node/startup.sh

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

# Use the embedded startup script
ENTRYPOINT ["/home/node/startup.sh"]
