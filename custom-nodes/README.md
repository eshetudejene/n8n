# Pre-installed Community Nodes for n8n on Render

This directory contains configuration for pre-installing community nodes in your n8n instance on Render.

## How It Works

1. The `package.json` file in this directory lists the community nodes that will be pre-installed.
2. The `install-nodes.js` script handles the installation of these nodes during the build process.
3. The custom build script (`custom-build.sh` in the root directory) runs this installation script after the standard n8n build.

## Adding More Community Nodes

To add more community nodes:

1. Edit the `package.json` file in this directory.
2. Add the desired community node to the `dependencies` section with its version.
3. Commit and push your changes to trigger a new deployment on Render.

Example:
```json
"dependencies": {
  "n8n-nodes-document-generator": "^0.7.0",
  "n8n-nodes-chatwoot": "^0.1.0",
  "n8n-nodes-imap": "^0.1.0",
  "new-community-node": "^1.0.0"
}
```

## Currently Installed Community Nodes

- **n8n-nodes-document-generator**: Generate documents from templates
- **n8n-nodes-chatwoot**: Integration with Chatwoot customer engagement platform
- **n8n-nodes-imap**: IMAP email integration

## Troubleshooting

If you encounter issues with the pre-installed community nodes:

1. Check the build logs on Render to see if there were any errors during installation.
2. Verify that the node versions in `package.json` are compatible with your n8n version.
3. Try updating the node versions to the latest available.

## Notes

- This approach embeds the community nodes directly into your n8n instance during the build process.
- No persistent disk is required since the nodes are part of the application code.
- The nodes will be reinstalled on each deployment, ensuring they're always available.
