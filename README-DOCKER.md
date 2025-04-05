# n8n on Render with Community Nodes

This repository contains a Docker-based setup for running n8n on Render with pre-installed community nodes.

## Overview

This approach uses a custom Docker image that extends the official n8n image and pre-installs the following community nodes:

- n8n-nodes-document-generator
- n8n-nodes-chatwoot
- n8n-nodes-imap
- n8n-nodes-puppeteer
- n8n-nodes-mcp

## How It Works

1. The `Dockerfile` extends the official n8n image
2. Community nodes are installed during the Docker build process
3. Configuration for the nodes is included in the image
4. Render deploys this custom Docker image instead of building from source

## Advantages of This Approach

- **Avoids Memory Issues**: Building n8n from source on Render's free tier often results in memory errors
- **Reliable Node Installation**: Community nodes are baked into the Docker image
- **Faster Deployment**: No need to build n8n from source on every deployment
- **Persistent Storage**: Uses Render's disk feature to persist data

## Configuration

The `render.yaml` file includes:

- Docker deployment configuration
- Environment variables for n8n and community nodes
- Supabase database connection settings
- Persistent disk configuration

## Supabase Integration

This setup is designed to work with Supabase as the database backend. You need to:

1. Replace the placeholder values in `render.yaml` with your actual Supabase credentials:
   - `YOUR_SUPABASE_HOST`
   - `YOUR_SUPABASE_PASSWORD`

2. Make sure your Supabase database is properly configured with the necessary permissions.

## Customizing Community Nodes

To add or remove community nodes:

1. Edit the `Dockerfile` to change the list of npm packages to install
2. Update the JSON configuration in the `echo` command that creates `n8n.json`
3. Commit and push your changes to trigger a new deployment

## Troubleshooting

If community nodes are not appearing:

1. Check the n8n logs for any errors related to node loading
2. Verify that the persistent disk is properly mounted
3. Make sure all environment variables are correctly set
4. Try restarting the n8n service on Render

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Render Documentation](https://render.com/docs)
- [Supabase Documentation](https://supabase.com/docs)
