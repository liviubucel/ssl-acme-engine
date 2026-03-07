#!/bin/bash

# renew.sh
# Automatically renew all certificates managed by ACME.sh before expiration.
#
# ACME.sh renews certificates when they are within 30 days of expiration by default.
# Run this script periodically (e.g., via cron or a scheduler) to keep certificates valid.
#
# Example cron entry (twice daily):
#   0 0,12 * * * bash /app/renew.sh >> /var/log/acme-renew.log 2>&1

set -e

export PATH="$HOME/.acme.sh:$PATH"

echo "=== ACME SSL Engine - Certificate Renewal ==="

# Renew all certificates that are near expiration
acme.sh --renew-all

echo "=== Certificate renewal complete ==="
