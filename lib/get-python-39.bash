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

# Install pyenv dependencies
install_pyenv_deps() {
    local dist
    dist=$(get_linux_dist)

    case "$dist" in
        ubuntu|debian)
            echo "Installing pyenv dependencies for Ubuntu/Debian..."
            apt-get update
            apt-get install -y make build-essential libssl-dev zlib1g-dev \
                libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
                liblzma-dev python-openssl git
            ;;
        centos|rhel|fedora)
            echo "Installing pyenv dependencies for CentOS/RHEL/Fedora..."
            yum install -y make gcc zlib-devel bzip2 bzip2-devel readline-devel \
                sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel \
                git
            ;;
        *)
            echo "Unsupported Linux distribution: $dist"
            exit 1
            ;;
    esac
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
            # Install pyenv dependencies
            install_pyenv_deps
            
            # Install pyenv if not exists
            if ! command_exists pyenv; then
                echo "Installing pyenv..."
                curl https://pyenv.run | bash
                
                # Update shell config to include pyenv
                echo '
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"
' >> ~/.bashrc
                source ~/.bashrc
            fi
            
            # Install Python 3.9
            pyenv install 3.9.13
            pyenv global 3.9.13
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

echo "Starting Python 3.9 installation..."
install_python39
 source ~/.bashrc
