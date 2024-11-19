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
                    # Use local user installation method
                    if [ ! -d "$HOME/.local/bin" ]; then
                        mkdir -p "$HOME/.local/bin"
                    fi
                    
                    # Download Python source and compile locally
                    cd /tmp
                    wget https://www.python.org/ftp/python/3.9.13/Python-3.9.13.tgz
                    tar xzf Python-3.9.13.tgz
                    cd Python-3.9.13
                    
                    # Configure and install to user's local directory
                    ./configure --prefix="$HOME/.local" --enable-optimizations
                    make
                    make install
                    
                    # Update PATH
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
                    source ~/.bashrc
                    ;;
                    
                centos|rhel|fedora)
                    echo "Installing Python 3.9 on CentOS/RHEL/Fedora..."
                    # Similar local user installation method
                    if [ ! -d "$HOME/.local/bin" ]; then
                        mkdir -p "$HOME/.local/bin"
                    fi
                    
                    # Download Python source and compile locally
                    cd /tmp
                    wget https://www.python.org/ftp/python/3.9.13/Python-3.9.13.tgz
                    tar xzf Python-3.9.13.tgz
                    cd Python-3.9.13
                    
                    # Configure and install to user's local directory
                    ./configure --prefix="$HOME/.local" --enable-optimizations
                    make
                    make install
                    
                    # Update PATH
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
                    source ~/.bashrc
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

# Create symbolic links in user's local bin
create_python_links() {
    if command_exists python3.9; then
        # Create links in user's local bin
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v python3.9)" "$HOME/.local/bin/python3.9"
        ln -sf "$(command -v python3.9)" "$HOME/.local/bin/python"
        echo "Created Python symbolic links in $HOME/.local/bin"
    fi
}

echo "Starting Python 3.9 installation..."
install_python39
create_python_links
