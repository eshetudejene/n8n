#!/usr/bin/env node

/**
 * This script installs community nodes during the build process
 * It's designed to work with Render's deployment process
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Path to n8n's node_modules directory
const n8nNodeModulesPath = path.resolve(__dirname, '../node_modules/n8n/node_modules');

// Path to our custom nodes package.json
const customNodesPackageJsonPath = path.resolve(__dirname, 'package.json');

// Read our custom nodes package.json
const customNodesPackageJson = JSON.parse(fs.readFileSync(customNodesPackageJsonPath, 'utf8'));

// Get the list of community nodes we want to install
const communityNodes = Object.keys(customNodesPackageJson.dependencies || {});

console.log('Installing community nodes...');

// Install each community node
communityNodes.forEach(nodeName => {
  const version = customNodesPackageJson.dependencies[nodeName];
  console.log(`Installing ${nodeName}@${version}...`);

  try {
    // Install the node package
    execSync(`npm install ${nodeName}@${version} --no-save`, {
      stdio: 'inherit',
      cwd: __dirname
    });

    // Create the directory in n8n's node_modules if it doesn't exist
    const nodeDestDir = path.join(n8nNodeModulesPath, nodeName);
    if (!fs.existsSync(nodeDestDir)) {
      fs.mkdirSync(nodeDestDir, { recursive: true });
    }

    // Copy the installed node to n8n's node_modules
    const nodeSourceDir = path.join(__dirname, 'node_modules', nodeName);
    execSync(`cp -r ${nodeSourceDir}/* ${nodeDestDir}/`, {
      stdio: 'inherit'
    });

    console.log(`Successfully installed ${nodeName}`);
  } catch (error) {
    console.error(`Failed to install ${nodeName}: ${error.message}`);
  }
});

console.log('Community nodes installation completed');
