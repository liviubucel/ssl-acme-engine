#!/bin/bash

set -e

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
  echo "Domain missing"
  exit 1
fi

echo "=== ACME SSL Engine - Certificate Issuance ==="
echo "Domain: $DOMAIN"

export PATH="$HOME/.acme.sh:$PATH"

# Set Let's Encrypt as default CA
acme.sh --set-default-ca --server letsencrypt

# Issue certificate using Cloudflare DNS API
acme.sh --issue \
  --dns dns_cf \
  -d "$DOMAIN" \
  --keylength ec-256

# Install certificate to local folder
mkdir -p /app/certs

acme.sh --install-cert -d "$DOMAIN" \
  --key-file /app/certs/$DOMAIN.key \
  --fullchain-file /app/certs/$DOMAIN.crt

echo "Certificate generated successfully"

echo "CRT: /app/certs/$DOMAIN.crt"
echo "KEY: /app/certs/$DOMAIN.key"
