#!/bin/bash

# Check if pyenv is installed
if ! command -v pyenv &> /dev/null; then
    echo "Installing pyenv..."
    
    # Clone pyenv repository
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    
    # Set up shell environment
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    
    # Source the updated profile
    source ~/.bashrc
fi

# Install Python 3.9 using pyenv
pyenv install 3.9.16

# Set global Python version
pyenv global 3.9.16

# Verify installation
python3 --version
