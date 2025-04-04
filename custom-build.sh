#!/bin/bash

# Custom build script for n8n on Render
set -e

echo "Starting custom build process for n8n with community nodes..."

# Run the standard n8n build
echo "Running standard n8n build..."
pnpm install --frozen-lockfile
pnpm run build

# Install custom community nodes
echo "Installing custom community nodes..."
cd custom-nodes
npm install
node install-nodes.js
cd ..

echo "Build completed successfully!"
