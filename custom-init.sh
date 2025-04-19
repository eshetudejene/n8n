#!/bin/bash

# Remove custom MCP nodes if they exist
echo "Checking for custom MCP nodes to remove..."

# Check user folder locations
if [ -d "/home/node/.n8n/custom/nodes/mcp" ]; then
  echo "Removing MCP nodes from user folder..."
  rm -rf /home/node/.n8n/custom/nodes/mcp
fi

if [ -d "/home/node/.n8n/custom/nodes/mcpClient" ]; then
  echo "Removing MCP client nodes from user folder..."
  rm -rf /home/node/.n8n/custom/nodes/mcpClient
fi

# Check custom extensions locations
if [ -d "/opt/render/project/src/custom-extensions/n8n-nodes-mcp" ]; then
  echo "Removing MCP nodes from custom extensions..."
  rm -rf /opt/render/project/src/custom-extensions/n8n-nodes-mcp
fi

# Check for any npm packages
if npm list -g | grep -q "n8n-nodes-mcp"; then
  echo "Removing globally installed MCP nodes..."
  npm uninstall -g n8n-nodes-mcp
fi

echo "Custom MCP nodes removal complete. Using native n8n MCP nodes instead."

# Continue with normal startup
exec "$@"
