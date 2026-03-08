#!/bin/bash

# renew.sh
# Verify DNS challenge and issue certificate for a specific domain.
# After the user has added the TXT record, this script tells acme.sh
# to check the DNS and complete certificate issuance.
#
# Usage: bash /app/renew.sh <domain>

set -e

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
  echo '{"error":"Domain missing"}'
  exit 1
fi

export PATH="$HOME/.acme.sh:$PATH"

# verify DNS and issue certificate
OUTPUT=$(acme.sh --renew \
  -d "$DOMAIN" \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please \
  --ecc 2>&1 || true)

echo "$OUTPUT"
