#!/bin/bash

# Flexible Python Installation Script (No Sudo, No Compilation)
set -e

# Default Python version if not specified
PYTHON_VERSION="3.9.0"

# Function to extract major.minor version
get_major_minor() {
    echo "$1" | cut -d. -f1-2
}

PYTHON_MAJOR_MINOR=$(get_major_minor "$PYTHON_VERSION")

# Detect operating system
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

# Installation directory
INSTALL_DIR="$HOME/.local/python-$PYTHON_VERSION"
BIN_DIR="$INSTALL_DIR/bin"

# Create installation directories
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# Download URL base
BASE_URL="https://www.python.org/ftp/python/$PYTHON_VERSION"

# Determine download URL based on OS
case "$OS" in
    darwin)
        FILENAME="python-$PYTHON_VERSION-macos11.pkg"
        DOWNLOAD_URL="$BASE_URL/$FILENAME"
        ;;
    linux)
        FILENAME="Python-$PYTHON_VERSION-linux-x86_64.tar.xz"
        DOWNLOAD_URL="$BASE_URL/$FILENAME"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Download Python
echo "Downloading Python $PYTHON_VERSION for $OS..."
curl -L "$DOWNLOAD_URL" -o "$INSTALL_DIR/$FILENAME"

# Extract based on OS
case "$OS" in
    darwin)
        xar -xf "$INSTALL_DIR/$FILENAME" -C "$INSTALL_DIR"
        gunzip -dc "$INSTALL_DIR/python-$PYTHON_VERSION-macos11.pkg/Payload" | cpio -i
        ;;
    linux)
        tar -xf "$INSTALL_DIR/$FILENAME" -C "$INSTALL_DIR" --strip-components=1
        ;;
esac

# Clean up downloaded file
rm "$INSTALL_DIR/$FILENAME"

# Create symbolic links
ln -sf "$INSTALL_DIR/bin/python3" "$BIN_DIR/python$PYTHON_MAJOR_MINOR"
ln -sf "$INSTALL_DIR/bin/pip3" "$BIN_DIR/pip$PYTHON_MAJOR_MINOR"

# Update PATH
SHELL_CONFIG="$HOME/.bashrc"
[[ "$SHELL" == *"zsh"* ]] && SHELL_CONFIG="$HOME/.zshrc"

# Append PATH update (if not already exists)
if ! grep -q "$BIN_DIR" "$SHELL_CONFIG"; then
    echo "export PATH='$BIN_DIR:\$PATH'" >> "$SHELL_CONFIG"
fi

# Verify installation
"$BIN_DIR/python$PYTHON_MAJOR_MINOR" --version

echo "Python $PYTHON_VERSION installed successfully to $INSTALL_DIR"
echo "Please restart your terminal or run 'source $SHELL_CONFIG'"
