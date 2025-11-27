#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Installing dotfiles from ${DOTFILES_DIR}"

# Detect OS and install dependencies
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "$ID"
        else
            echo "linux-unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

install_dependencies() {
    local os=$(detect_os)

    echo "Detected OS: $os"

    case "$os" in
        rhel|centos)
            echo -e "${YELLOW}Installing dependencies for RHEL/CentOS...${NC}"

            # Install EPEL repository if not already installed
            if ! rpm -q epel-release &>/dev/null; then
                echo "Installing EPEL repository..."
                sudo dnf install -y epel-release
            fi

            # Install required build tools and dependencies
            echo "Installing build tools and dependencies..."
            sudo dnf install -y \
                git \
                curl \
                tmux \
                gcc \
                make \
                cmake \
                nodejs \
                npm

            # Install neovim from EPEL or build from source
            if rpm -q neovim &>/dev/null; then
                echo -e "${GREEN}Neovim already installed${NC}"
            else
                echo "Installing neovim..."
                # Try to install from package manager first
                if sudo dnf install -y neovim 2>/dev/null; then
                    echo -e "${GREEN}Neovim installed via dnf${NC}"
                else
                    # If package manager fails, build from source
                    echo "Building neovim from source..."

                    # Install build dependencies
                    sudo dnf install -y \
                        git \
                        gcc \
                        g++ \
                        cmake \
                        make \
                        pkg-config \
                        unzip \
                        gettext-devel

                    # Clone and build neovim
                    local temp_dir=$(mktemp -d)
                    cd "$temp_dir"
                    git clone --depth 1 https://github.com/neovim/neovim.git
                    cd neovim
                    make CMAKE_BUILD_TYPE=Release
                    sudo make install
                    cd "$DOTFILES_DIR"
                    rm -rf "$temp_dir"
                    echo -e "${GREEN}Neovim built and installed from source${NC}"
                fi
            fi

            # Install Claude Code CLI via npm
            if ! command -v claude &> /dev/null; then
                echo -e "${YELLOW}Installing Claude Code CLI via npm...${NC}"
                sudo npm install -g claude-code
            else
                echo -e "${GREEN}claude-code is already installed${NC}"
                echo -e "${YELLOW}Checking for updates...${NC}"
                sudo npm update -g claude-code || echo -e "${GREEN}claude-code is up to date${NC}"
            fi
            ;;
        fedora)
            echo -e "${YELLOW}Installing dependencies for Fedora...${NC}"
            sudo dnf install -y \
                git \
                curl \
                neovim \
                tmux \
                gcc \
                make \
                cmake \
                nodejs \
                npm

            # Install Claude Code CLI via npm
            if ! command -v claude &> /dev/null; then
                echo -e "${YELLOW}Installing Claude Code CLI via npm...${NC}"
                sudo npm install -g claude-code
            else
                echo -e "${GREEN}claude-code is already installed${NC}"
                echo -e "${YELLOW}Checking for updates...${NC}"
                sudo npm update -g claude-code || echo -e "${GREEN}claude-code is up to date${NC}"
            fi
            ;;
        ubuntu|debian)
            echo -e "${YELLOW}Installing dependencies for Debian/Ubuntu...${NC}"
            sudo apt-get update
            sudo apt-get install -y \
                git \
                curl \
                neovim \
                tmux \
                build-essential \
                cmake \
                nodejs \
                npm

            # Install Claude Code CLI via npm
            if ! command -v claude &> /dev/null; then
                echo -e "${YELLOW}Installing Claude Code CLI via npm...${NC}"
                sudo npm install -g claude-code
            else
                echo -e "${GREEN}claude-code is already installed${NC}"
                echo -e "${YELLOW}Checking for updates...${NC}"
                sudo npm update -g claude-code || echo -e "${GREEN}claude-code is up to date${NC}"
            fi
            ;;
        macos)
            echo -e "${YELLOW}Installing dependencies for macOS...${NC}"

            # Check if Homebrew is installed
            if ! command -v brew &> /dev/null; then
                echo "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

                # Add Homebrew to PATH for this session
                if [[ $(uname -m) == 'arm64' ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            else
                echo -e "${GREEN}Homebrew is already installed${NC}"
            fi

            # Function to install or upgrade a package
            install_or_upgrade() {
                local package=$1
                if brew list "$package" &> /dev/null; then
                    echo -e "${GREEN}$package is already installed${NC}"
                    echo -e "${YELLOW}Checking for updates...${NC}"
                    brew upgrade "$package" || echo -e "${GREEN}$package is up to date${NC}"
                else
                    echo -e "${YELLOW}Installing $package...${NC}"
                    brew install "$package"
                fi
            }

            # Install or upgrade required packages
            install_or_upgrade "git"
            install_or_upgrade "curl"
            install_or_upgrade "neovim"
            install_or_upgrade "tmux"
            install_or_upgrade "cmake"
            install_or_upgrade "node"

            # Install Claude Code CLI via npm
            if ! command -v claude &> /dev/null; then
                echo -e "${YELLOW}Installing Claude Code CLI via npm...${NC}"
                npm install -g claude-code
            else
                echo -e "${GREEN}claude-code is already installed${NC}"
                echo -e "${YELLOW}Checking for updates...${NC}"
                npm update -g claude-code || echo -e "${GREEN}claude-code is up to date${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}Unsupported OS: $os${NC}"
            echo "Please install the following manually:"
            echo "  - git"
            echo "  - neovim"
            echo "  - tmux"
            echo "  - zsh (optional)"
            ;;
    esac
}

# Parse command line arguments
SKIP_CLAUDE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-claude)
            SKIP_CLAUDE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-claude]"
            exit 1
            ;;
    esac
done

# Ask user if they want to install dependencies
read -p "Install system dependencies? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_dependencies
fi

# Function to backup existing file/directory
backup_if_exists() {
    local target=$1
    if [ -e "$target" ] || [ -L "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backing up existing $target to $backup${NC}"
        mv "$target" "$backup"
    fi
}

# Function to create symlink
create_symlink() {
    local source=$1
    local target=$2

    backup_if_exists "$target"

    echo -e "${GREEN}Linking $target -> $source${NC}"
    ln -sf "$source" "$target"
}

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p ~/.bin
mkdir -p ~/.config

# Install devopen script
echo "Installing devopen script..."
create_symlink "${DOTFILES_DIR}/scripts/devopen" ~/.bin/devopen
chmod +x ~/.bin/devopen

# Ensure ~/.bin is in PATH
if [[ ":$PATH:" != *":$HOME/.bin:"* ]]; then
    echo -e "${YELLOW}Adding ~/.bin to PATH in ~/.zshrc${NC}"

    # Add to .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'export PATH="$HOME/.bin:$PATH"' "$HOME/.zshrc"; then
            echo 'export PATH="$HOME/.bin:$PATH"' >> "$HOME/.zshrc"
            echo -e "${GREEN}Added PATH export to ~/.zshrc${NC}"
        fi
    fi

    # Add to .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q 'export PATH="$HOME/.bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/.bin:$PATH"' >> "$HOME/.bashrc"
            echo -e "${GREEN}Added PATH export to ~/.bashrc${NC}"
        fi
    fi
fi

# Install tmux config
echo "Installing tmux config..."
create_symlink "${DOTFILES_DIR}/tmux/.tmux.conf" ~/.tmux.conf

# Install neovim config
echo "Installing neovim config..."
create_symlink "${DOTFILES_DIR}/nvim" ~/.config/nvim

# Install Claude Code config (unless skipped)
if [ "$SKIP_CLAUDE" = false ]; then
    echo "Installing Claude Code config..."
    mkdir -p ~/.claude
    create_symlink "${DOTFILES_DIR}/claude-code/settings.json" ~/.claude/settings.json
fi

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Make sure ~/.bin is in your PATH"
echo "  2. Restart your terminal or source your shell config"
echo "  3. For neovim: Open nvim and run :Lazy sync if using lazy.nvim"
echo "  4. For tmux: Start tmux and press prefix + I to install plugins (if using TPM)"
