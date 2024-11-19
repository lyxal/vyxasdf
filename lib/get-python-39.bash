#!/bin/bash

# Python 3.9 Installation Script (No Sudo, No Compilation)
set -e

# Detect operating system
OS=$(uname -s)

# Set download URL and filename based on OS
if [[ "$OS" == "Darwin" ]]; then
    # macOS
    PYTHON_URL="https://www.python.org/ftp/python/3.9.16/python-3.9.16-macos11.pkg"
    FILENAME="python-3.9.16-macos11.pkg"
elif [[ "$OS" == "Linux" ]]; then
    # Linux (using pre-compiled binary)
    PYTHON_URL="https://www.python.org/ftp/python/3.9.16/Python-3.9.16-linux-x86_64.tar.xz"
    FILENAME="Python-3.9.16-linux-x86_64.tar.xz"
else
    echo "Unsupported operating system"
    exit 1
fi

# Create installation directory
INSTALL_DIR="$HOME/python3.9"
mkdir -p "$INSTALL_DIR"

# Download Python
echo "Downloading Python 3.9..."
curl -L "$PYTHON_URL" -o "$INSTALL_DIR/$FILENAME"

# Extract or install based on OS
if [[ "$OS" == "Darwin" ]]; then
    # For macOS, expand the package
    xar -xf "$INSTALL_DIR/$FILENAME" -C "$INSTALL_DIR"
    gunzip -dc "$INSTALL_DIR/python-3.9.16-macos11.pkg/Payload" | cpio -i
elif [[ "$OS" == "Linux" ]]; then
    # For Linux, extract tarball
    tar -xf "$INSTALL_DIR/$FILENAME" -C "$INSTALL_DIR" --strip-components=1
fi

# Clean up downloaded file
rm "$INSTALL_DIR/$FILENAME"

# Add to PATH in .bashrc or .bash_profile
echo "export PATH='$INSTALL_DIR/bin:\$PATH'" >> "$HOME/.bashrc"

# Verify installation
"$INSTALL_DIR/bin/python3" --version

echo "Python 3.9 installed successfully to $INSTALL_DIR"
