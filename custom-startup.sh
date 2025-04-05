#!/bin/bash
set -e

echo "Starting custom n8n startup script..."

# Create necessary directories
mkdir -p /home/node/.n8n/nodes

# Check if nodes are already installed
if [ ! -d "/home/node/.n8n/nodes/n8n-nodes-document-generator" ]; then
  echo "Installing community nodes..."

  # Create a temporary directory for installing nodes
  mkdir -p /tmp/n8n-nodes
  cd /tmp/n8n-nodes

  # Initialize npm and install nodes
  npm init -y
  npm install n8n-nodes-document-generator@1.0.10 \
    n8n-nodes-chatwoot@0.1.40 \
    n8n-nodes-imap@2.5.0 \
    n8n-nodes-puppeteer@1.4.1 \
    n8n-nodes-mcp@0.1.14

  # Copy the installed nodes to the n8n nodes directory
  cp -r node_modules/* /home/node/.n8n/nodes/

  # Clean up
  cd /
  rm -rf /tmp/n8n-nodes
else
  echo "Community nodes already installed, skipping installation."
fi

# Ensure n8n.json config exists
if [ ! -f "/home/node/.n8n/n8n.json" ]; then
  echo "Creating n8n.json configuration..."
  cat > /home/node/.n8n/n8n.json << EOL
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
fi

# Debug information
echo "==== DEBUG: INSTALLED NODES ===="
ls -la /home/node/.n8n/nodes
echo "==== DEBUG: NODE MODULES ===="
find /home/node/.n8n/nodes -type d -maxdepth 2 | sort
echo "==== DEBUG: N8N CONFIG ===="
cat /home/node/.n8n/n8n.json
echo "==== DEBUG: ENVIRONMENT VARIABLES ===="
env | grep N8N
echo "==== DEBUG END ===="

# Create a simpler approach - directly modify the n8n config
echo "Ensuring community nodes are enabled in config..."
cat > /home/node/.n8n/config << EOL
module.exports = {
  nodes: {
    include: [
      'n8n-nodes-document-generator',
      'n8n-nodes-chatwoot',
      'n8n-nodes-imap',
      'n8n-nodes-puppeteer',
      'n8n-nodes-mcp'
    ],
  },
  // Make sure community nodes can be loaded
  communityPackages: {
    enabled: true,
  },
};
EOL

# Start n8n
echo "Starting n8n..."
exec n8n start
