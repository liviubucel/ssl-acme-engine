#!/bin/bash

set -e

DOMAIN=$1
CA=$2

if [ -z "$DOMAIN" ]; then
  echo '{"error":"Domain missing"}'
  exit 1
fi

if [ -z "$CA" ]; then
  CA="letsencrypt"
fi

export PATH="$HOME/.acme.sh:$PATH"

echo "Generating DNS challenge for $DOMAIN"

# setează CA
acme.sh --set-default-ca --server $CA

# rulează manual DNS challenge
OUTPUT=$(acme.sh --issue \
  --manual \
  -d "$DOMAIN" \
  --keylength ec-256 2>&1 || true)

echo "$OUTPUT"
