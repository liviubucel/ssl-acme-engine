#!/bin/bash

set -e

# Run install.sh if ACME.sh is not yet installed
if [ ! -f "$HOME/.acme.sh/acme.sh" ]; then
    echo "ACME.sh not found. Running install.sh..."
    bash "$(dirname "$0")/install.sh"
fi

# Initialize ACME.sh environment
export PATH="$HOME/.acme.sh:$PATH"

echo "ACME SSL Engine started successfully"

# Keep the process alive so Railway does not stop the service
while true; do
    sleep 3600
done
