FROM alpine:3.19

# Install required tools
RUN apk add --no-cache \
    bash \
    curl \
    socat \
    openssl

WORKDIR /app

# Copy all project scripts
COPY install.sh  /app/install.sh
COPY start.sh    /app/start.sh
COPY issue-cert.sh /app/issue-cert.sh
COPY renew.sh    /app/renew.sh

# Make scripts executable
RUN chmod +x /app/install.sh /app/start.sh /app/issue-cert.sh /app/renew.sh

CMD ["bash", "/app/start.sh"]
