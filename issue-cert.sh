#!/bin/bash

set -e

DOMAIN=$1
CA=$2

if [ -z "$DOMAIN" ]; then
  echo "Domain missing"
  exit 1
fi

if [ -z "$CA" ]; then
  CA="letsencrypt"
fi

export PATH="$HOME/.acme.sh:$PATH"

echo "=== ACME SSL Engine ==="
echo "Domain: $DOMAIN"
echo "CA: $CA"

# seteaza Certificate Authority
acme.sh --set-default-ca --server $CA

# genereaza challenge DNS
acme.sh --issue \
  --dns \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please \
  -d "$DOMAIN" \
  --keylength ec-256

echo ""
echo "TXT record required:"
echo "_acme-challenge.$DOMAIN"
