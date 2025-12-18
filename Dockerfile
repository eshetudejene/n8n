FROM node:18-alpine

WORKDIR /app

# Install dependencies and n8n packages in a single RUN command to reduce memory usage
RUN npm install -g n8n && \
    npm install -g n8n-nodes-document-generator n8n-nodes-imap

EXPOSE 5678

CMD ["n8n", "start"]
