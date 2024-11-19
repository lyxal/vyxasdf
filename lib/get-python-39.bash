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
                    echo "Installing Python 3.9 on Ubuntu/Debian using pyenv..."
                    # Install pyenv for user-level Python management
                    if ! command_exists pyenv; then
                        curl https://pyenv.run | bash
                        
                        # Update shell config to include pyenv
                        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
                        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
                        echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
                        source ~/.bashrc
                    fi
                    
                    # Install Python 3.9
                    pyenv install 3.9.13
                    pyenv global 3.9.13
                    ;;
                    
                centos|rhel|fedora)
                    echo "Installing Python 3.9 on CentOS/RHEL/Fedora using pyenv..."
                    # Install pyenv for user-level Python management
                    if ! command_exists pyenv; then
                        curl https://pyenv.run | bash
                        
                        # Update shell config to include pyenv
                        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
                        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
                        echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
                        source ~/.bashrc
                    fi
                    
                    # Install Python 3.9
                    pyenv install 3.9.13
                    pyenv global 3.9.13
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

echo "Starting Python 3.9 installation..."
install_python39
