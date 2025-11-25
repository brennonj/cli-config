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
mkdir -p ~/bin
mkdir -p ~/.config

# Install devopen script
echo "Installing devopen script..."
create_symlink "${DOTFILES_DIR}/scripts/devopen" ~/bin/devopen
chmod +x ~/bin/devopen

# Ensure ~/bin is in PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo -e "${YELLOW}Adding ~/bin to PATH in ~/.zshrc${NC}"

    # Add to .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.zshrc"; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
            echo -e "${GREEN}Added PATH export to ~/.zshrc${NC}"
        fi
    fi

    # Add to .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
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

# Install Claude Code config
echo "Installing Claude Code config..."
mkdir -p ~/.claude
create_symlink "${DOTFILES_DIR}/claude-code/settings.json" ~/.claude/settings.json

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Make sure ~/bin is in your PATH"
echo "  2. Restart your terminal or source your shell config"
echo "  3. For neovim: Open nvim and run :Lazy sync if using lazy.nvim"
echo "  4. For tmux: Start tmux and press prefix + I to install plugins (if using TPM)"
