#!/bin/bash

# Custom build script for n8n on Render
set -e

echo "Starting custom build process for n8n with community nodes..."

# Increase Node.js memory limit for the build process
export NODE_OPTIONS="--max-old-space-size=4096"

# Run the standard n8n build with memory optimizations
echo "Running standard n8n build..."
pnpm install --frozen-lockfile

# Build packages individually with reduced parallelism to avoid memory issues
echo "Building packages with memory optimization..."
pnpm run build:backend --concurrency=1
pnpm run build:frontend

# Create .n8n directory structure
echo "Setting up .n8n directory..."
mkdir -p /opt/render/.n8n
mkdir -p /opt/render/.n8n/nodes

# Install custom community nodes directly to the .n8n directory
echo "Installing custom community nodes..."
cd custom-nodes

# Install each community node directly to the .n8n/nodes directory
npm_config_prefix=/opt/render/.n8n npm install n8n-nodes-document-generator@1.0.10
npm_config_prefix=/opt/render/.n8n npm install n8n-nodes-chatwoot@0.1.40
npm_config_prefix=/opt/render/.n8n npm install n8n-nodes-imap@2.5.0
npm_config_prefix=/opt/render/.n8n npm install n8n-nodes-puppeteer@1.4.1
npm_config_prefix=/opt/render/.n8n npm install n8n-nodes-mcp@0.1.14

# Create n8n.json config file to enable community nodes
echo "Creating n8n configuration..."
cat > /opt/render/.n8n/n8n.json << EOL
{
  "nodes": {
    "include": [
      "n8n-nodes-document-generator",
      "n8n-nodes-chatwoot",
      "n8n-nodes-imap",
      "n8n-nodes-puppeteer",
      "n8n-nodes-mcp"
    ]
  }
}
EOL

# Set proper permissions
chmod -R 755 /opt/render/.n8n

# Create a symbolic link to ensure n8n can find the nodes
ln -sf /opt/render/.n8n/nodes /opt/render/project/src/node_modules

echo "Build completed successfully!"
