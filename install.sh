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

install_dependencies() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}This install script only supports macOS.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Installing dependencies for macOS...${NC}"

    # Ensure ~/.bin is in PATH for this session so freshly installed binaries are usable immediately
    export PATH="$HOME/.bin:$PATH"

    # tmux is required by devopen and is expected to already be installed
    # (e.g. via `brew install tmux`); devopen itself checks for it at runtime.
    if ! command -v tmux &>/dev/null; then
        echo -e "${YELLOW}Warning: tmux is not installed. Install with: brew install tmux${NC}"
    else
        echo -e "${GREEN}tmux is already installed${NC}"
    fi

    # Install Neovim via direct download from GitHub releases
    local arch
    [[ $(uname -m) == 'arm64' ]] && arch="arm64" || arch="x86_64"

    if ! command -v nvim &>/dev/null; then
        echo -e "${YELLOW}Installing Neovim...${NC}"
        local tmp
        tmp=$(mktemp -d)
        curl -fsSL "https://github.com/neovim/neovim/releases/download/stable/nvim-macos-${arch}.tar.gz" -o "$tmp/nvim.tar.gz"
        tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
        mkdir -p ~/.local
        cp -r "$tmp/nvim-macos-${arch}/." ~/.local/
        rm -rf "$tmp"
        echo -e "${GREEN}Neovim installed${NC}"
    else
        echo -e "${GREEN}Neovim is already installed${NC}"
    fi

    # Install Claude Code CLI via official installer
    if ! command -v claude &>/dev/null; then
        echo -e "${YELLOW}Installing Claude Code CLI...${NC}"
        curl -fsSL https://claude.ai/install.sh | sh
    else
        echo -e "${GREEN}Claude Code CLI is already installed${NC}"
        echo -e "${YELLOW}Checking for updates...${NC}"
        claude update || echo -e "${GREEN}claude is up to date${NC}"
    fi
}

# Parse command line arguments
SKIP_CLAUDE=false
SKIP_NVIM=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-claude)
            SKIP_CLAUDE=true
            shift
            ;;
        --skip-nvim)
            SKIP_NVIM=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-claude] [--skip-nvim]"
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

# Install zsh config
echo "Installing zsh config..."
create_symlink "${DOTFILES_DIR}/zsh/.zshrc" ~/.zshrc

# Install tmux config
echo "Installing tmux config..."
create_symlink "${DOTFILES_DIR}/tmux/.tmux.conf" ~/.tmux.conf

# Install neovim config (unless skipped)
if [ "$SKIP_NVIM" = false ]; then
    echo "Installing neovim config..."
    create_symlink "${DOTFILES_DIR}/nvim" ~/.config/nvim
fi

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
