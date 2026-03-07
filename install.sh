#!/bin/bash

set -e

echo "=== ACME SSL Engine - Installation ==="

# Install required packages if missing (curl, openssl, socat)
PACKAGES_NEEDED=""

if ! command -v curl &>/dev/null; then
    PACKAGES_NEEDED="$PACKAGES_NEEDED curl"
fi

if ! command -v openssl &>/dev/null; then
    PACKAGES_NEEDED="$PACKAGES_NEEDED openssl"
fi

if ! command -v socat &>/dev/null; then
    PACKAGES_NEEDED="$PACKAGES_NEEDED socat"
fi

if [ -n "$PACKAGES_NEEDED" ]; then
    echo "Installing missing packages:$PACKAGES_NEEDED"
    if command -v apt-get &>/dev/null; then
        apt-get update -qq && apt-get install -y $PACKAGES_NEEDED
    elif command -v apk &>/dev/null; then
        apk add --no-cache $PACKAGES_NEEDED
    elif command -v yum &>/dev/null; then
        yum install -y $PACKAGES_NEEDED
    else
        echo "ERROR: No supported package manager found. Please install:$PACKAGES_NEEDED manually." >&2
        exit 1
    fi
else
    echo "All required packages are already installed."
fi

# Install ACME.sh using the official installation command
if [ ! -f "$HOME/.acme.sh/acme.sh" ]; then
    echo "Installing ACME.sh..."
    curl https://get.acme.sh | sh
else
    echo "ACME.sh is already installed."
fi

# Verify installation
echo "Verifying ACME.sh installation..."
if [ ! -f "$HOME/.acme.sh/acme.sh" ]; then
    echo "ERROR: ACME.sh installation failed." >&2
    exit 1
fi

# Print the installed version
"$HOME/.acme.sh/acme.sh" --version

echo "=== Installation complete ==="
