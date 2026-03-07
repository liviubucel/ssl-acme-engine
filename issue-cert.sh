#!/bin/bash

# issue-cert.sh
# Demonstrates how to issue an SSL/TLS certificate using ACME.sh.
#
# IMPORTANT: This script is for demonstration purposes.
# Replace "example.com" with your actual domain before running.
# DNS API credentials must be configured before using the --dns flag.
# See: https://github.com/acmesh-official/acme.sh/wiki/dnsapi

set -e

export PATH="$HOME/.acme.sh:$PATH"

DOMAIN="${1:-example.com}"

echo "=== ACME SSL Engine - Certificate Issuance ==="
echo "Domain: $DOMAIN"

# Step 1: Set the default Certificate Authority to Let's Encrypt
echo "Step 1: Setting default CA to Let's Encrypt..."
acme.sh --set-default-ca --server letsencrypt

# Step 2: Issue a certificate using the DNS challenge
# The --dns flag instructs ACME.sh to use a DNS challenge for domain validation.
# For automated DNS validation, replace "dns" with your DNS provider plugin,
# for example: --dns dns_cf  (for Cloudflare)
echo "Step 2: Issuing certificate for $DOMAIN using DNS challenge..."
acme.sh --issue --dns -d "$DOMAIN" --yes-I-know-dns-manual-mode-enough-go-ahead-please

# Step 3: Certificates are stored automatically by ACME.sh
# Default storage location: ~/.acme.sh/<domain>/
echo "Step 3: Certificate files stored in: $HOME/.acme.sh/$DOMAIN/"
echo ""
echo "Certificate files:"
echo "  Certificate:  $HOME/.acme.sh/$DOMAIN/$DOMAIN.cer"
echo "  Private key:  $HOME/.acme.sh/$DOMAIN/$DOMAIN.key"
echo "  CA bundle:    $HOME/.acme.sh/$DOMAIN/ca.cer"
echo "  Full chain:   $HOME/.acme.sh/$DOMAIN/fullchain.cer"

echo "=== Certificate issuance complete ==="
