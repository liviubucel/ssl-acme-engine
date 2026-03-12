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


# set CA
acme.sh --set-default-ca --server $CA

# Prepare EAB params if needed
EAB_ARGS=""
if [ "$CA" = "ssl.com" ]; then
  if [ -n "$SSLCOM_EAB_KID" ] && [ -n "$SSLCOM_EAB_HMAC" ]; then
    EAB_ARGS="--eab-kid $SSLCOM_EAB_KID --eab-hmac-key $SSLCOM_EAB_HMAC"
  fi
elif [ "$CA" = "google" ] || [ "$CA" = "googletrust" ] || [ "$CA" = "google-trust" ]; then
  if [ -n "$GTS_EAB_KID" ] && [ -n "$GTS_EAB_HMAC" ]; then
    EAB_ARGS="--eab-kid $GTS_EAB_KID --eab-hmac-key $GTS_EAB_HMAC"
  fi
fi

# run manual DNS challenge
OUTPUT=$(acme.sh --issue \
  -d "$DOMAIN" \
  --dns \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please \
  --keylength ec-256 $EAB_ARGS 2>&1 || true)

# extract TXT record
TXT_NAME="_acme-challenge.$DOMAIN"
TXT_VALUE=$(echo "$OUTPUT" | grep "TXT value" | grep -o "'[^']*'" | tr -d "'" | head -1)

# fallback: try without quotes
if [ -z "$TXT_VALUE" ]; then
  TXT_VALUE=$(echo "$OUTPUT" | grep "TXT value" | sed 's/.*TXT value:[[:space:]]*//' | tr -d "'" | head -1)
fi

if [ -z "$TXT_VALUE" ]; then
  echo "{\"error\":\"Failed to extract DNS challenge value\",\"raw_output\":\"$(echo "$OUTPUT" | tail -5 | tr '\n' ' ')\"}"
  exit 1
fi

# JSON response for API
echo "{\"domain\":\"$DOMAIN\",\"dns_record\":\"$TXT_NAME\",\"txt_value\":\"$TXT_VALUE\"}"
