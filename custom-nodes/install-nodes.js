#!/usr/bin/env node

/**
 * This script installs community nodes during the build process
 * It's designed to work with Render's deployment process
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Possible paths to n8n's node_modules directory
const possiblePaths = [
  path.resolve(__dirname, '../node_modules/n8n/node_modules'),
  path.resolve(__dirname, '../node_modules'),
  '/opt/render/project/src/node_modules',
  '/usr/local/lib/node_modules/n8n/node_modules',
  '/usr/local/lib/node_modules'
];

// Find the correct n8n node_modules path
let n8nNodeModulesPath = null;
for (const p of possiblePaths) {
  if (fs.existsSync(p)) {
    console.log(`Found node_modules at: ${p}`);
    n8nNodeModulesPath = p;
    break;
  }
}

if (!n8nNodeModulesPath) {
  console.error('Could not find n8n node_modules directory!');
  process.exit(1);
}

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

    // Also try to copy to .n8n directory which is sometimes used for community nodes
    try {
      const n8nDir = path.resolve(process.env.HOME || '/root', '.n8n');
      const n8nNodesDir = path.join(n8nDir, 'nodes');

      if (!fs.existsSync(n8nNodesDir)) {
        fs.mkdirSync(n8nNodesDir, { recursive: true });
      }

      const nodeN8nDestDir = path.join(n8nNodesDir, nodeName);
      if (!fs.existsSync(nodeN8nDestDir)) {
        fs.mkdirSync(nodeN8nDestDir, { recursive: true });
      }

      execSync(`cp -r ${nodeSourceDir}/* ${nodeN8nDestDir}/`, {
        stdio: 'inherit'
      });

      console.log(`Also installed ${nodeName} to .n8n/nodes directory`);
    } catch (err) {
      console.log(`Note: Could not copy to .n8n directory: ${err.message}`);
    }

    console.log(`Successfully installed ${nodeName}`);
  } catch (error) {
    console.error(`Failed to install ${nodeName}: ${error.message}`);
  }
});

console.log('Community nodes installation completed');
