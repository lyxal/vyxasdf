#!/bin/bash

set -e

# Function to detect OS
get_os() {
    case "$(uname -s)" in
        Darwin*)    echo 'macos';;
        Linux*)     echo 'linux';;
        *)         echo 'unknown';;
    esac
}

# Function to detect Linux distribution
get_linux_dist() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Homebrew on macOS
install_homebrew() {
    if ! command_exists brew; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Main installation function
install_python39() {
    local os
    os=$(get_os)
    
    echo "Detected OS: $os"
    
    case "$os" in
        macos)
            install_homebrew
            echo "Installing Python 3.9 via Homebrew..."
            brew install python@3.9
            
            # Update PATH in shell config files
            for config_file in ~/.zshrc ~/.bashrc; do
                if [ -f "$config_file" ]; then
                    if ! grep -q 'python@3.9' "$config_file"; then
                        echo 'export PATH="/usr/local/opt/python@3.9/bin:$PATH"' >> "$config_file"
                    fi
                fi
            done
            ;;
            
        linux)
            local dist
            dist=$(get_linux_dist)
            
            case "$dist" in
                ubuntu|debian)
                    echo "Installing Python 3.9 on Ubuntu/Debian..."
                    sudo apt-get update
                    sudo apt-get install -y software-properties-common
                    sudo add-apt-repository -y ppa:deadsnakes/ppa
                    sudo apt-get update
                    sudo apt-get install -y python3.9 python3.9-venv python3.9-dev
                    ;;
                    
                centos|rhel|fedora)
                    echo "Installing Python 3.9 on CentOS/RHEL/Fedora..."
                    sudo dnf install -y python39 python39-devel
                    ;;
                    
                *)
                    echo "Unsupported Linux distribution: $dist"
                    exit 1
                    ;;
            esac
            ;;
            
        *)
            echo "Unsupported operating system"
            exit 1
            ;;
    esac
    
    # Verify installation
    if command_exists python3.9; then
        echo "Python 3.9 installed successfully!"
        echo "Python version:"
        python3.9 --version
    else
        echo "Installation may have failed. Please check the error messages above."
        exit 1
    fi
}

# Create symbolic links function
create_python_links() {
    if command_exists python3.9; then
        # Create aliases in /usr/local/bin
        sudo mkdir -p /usr/local/bin
        sudo ln -sf "$(command -v python3.9)" /usr/local/bin/python3.9
        sudo ln -sf "$(command -v python3.9)" /usr/local/bin/python
        echo "Created Python symbolic links in /usr/local/bin"
    fi
}