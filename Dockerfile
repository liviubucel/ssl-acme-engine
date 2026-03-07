FROM node:20-alpine

# Install required tools for ACME
RUN apk add --no-cache \
    bash \
    curl \
    socat \
    openssl

WORKDIR /app

# Copy project files
COPY . .

# Make scripts executable
RUN chmod +x /app/install.sh /app/start.sh /app/issue-cert.sh /app/renew.sh

# Install Node dependencies
RUN npm install

EXPOSE 8080

CMD ["node", "server.js"]
