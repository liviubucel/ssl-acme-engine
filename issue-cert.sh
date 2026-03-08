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

echo "=== ACME SSL Engine ==="
echo "Domain: $DOMAIN"
echo "CA: $CA"

# set CA
acme.sh --set-default-ca --server $CA

# run manual DNS challenge
OUTPUT=$(acme.sh --issue \
  -d "$DOMAIN" \
  --dns \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please \
  --keylength ec-256 2>&1 || true)

# extrage TXT record
TXT_NAME="_acme-challenge.$DOMAIN"
TXT_VALUE=$(echo "$OUTPUT" | grep "TXT value" | awk '{print $3}')

# raspuns JSON pentru API
echo "{"
echo "\"domain\":\"$DOMAIN\","
echo "\"dns_record\":\"$TXT_NAME\","
echo "\"txt_value\":\"$TXT_VALUE\""
echo "}"
