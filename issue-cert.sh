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

# setează CA
acme.sh --set-default-ca --server $CA

# rulează manual DNS challenge
OUTPUT=$(acme.sh --issue \
  -d "$DOMAIN" \
  --dns \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please \
  --keylength ec-256 2>&1 || true)

# extrage TXT record
TXT_NAME="_acme-challenge.$DOMAIN"
TXT_VALUE=$(echo "$OUTPUT" | grep "TXT value" | grep -o "'[^']*'" | tr -d "'" | head -1)

if [ -z "$TXT_VALUE" ]; then
  echo "{\"error\":\"Failed to extract DNS challenge value\",\"raw_output\":\"$(echo "$OUTPUT" | tail -5 | tr '\n' ' ')\"}"
  exit 1
fi

# raspuns JSON pentru API
echo "{\"domain\":\"$DOMAIN\",\"dns_record\":\"$TXT_NAME\",\"txt_value\":\"$TXT_VALUE\"}"
