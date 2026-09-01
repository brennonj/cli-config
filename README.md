# CLI Config

Personal development environment configuration for macOS.

## What's Included

- **devopen** - Custom script for opening projects in tmux/nvim
- **tmux** - Terminal multiplexer configuration
- **neovim** - Text editor configuration
- **zsh** - Shell configuration
- **Claude Code** - AI-powered coding assistant settings

## Quick Start

```bash
# Clone the repository
git clone git@github.com:brennonj/cli-config.git ~/.dotfiles

# Run the installation script
cd ~/.dotfiles
./install.sh
```

The install script will:
- Verify you're on macOS (the only supported platform)
- Check for tmux, devopen's one hard requirement (prints a `brew install tmux` hint if it's missing, since it isn't installed automatically)
- Install Neovim via direct download from GitHub releases, if not already installed
- Install/update the Claude Code CLI via the official installer
- Create symlinks from this repo to the appropriate locations (devopen, zsh, tmux, neovim, Claude Code settings)
- Backup any existing configs with timestamps
- Set up necessary directories
- Make scripts executable

## Manual Installation

If you prefer to set things up manually:

```bash
# Install Claude Code CLI
curl -fsSL https://claude.ai/install.sh | sh

# Link configs
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/nvim ~/.config/nvim
ln -sf ~/.dotfiles/scripts/devopen ~/.bin/devopen
ln -sf ~/.dotfiles/claude-code/settings.json ~/.claude/settings.json

# Make scripts executable
chmod +x ~/.bin/devopen

# Ensure ~/.bin is in PATH
export PATH="$HOME/.bin:$PATH"
```

## Structure

```
.dotfiles/
├── install.sh           # Installation script
├── scripts/
│   └── devopen         # Project opener script
├── tmux/
│   └── .tmux.conf      # Tmux configuration
├── zsh/
│   └── .zshrc          # Shell configuration
├── nvim/               # Neovim configuration
│   ├── init.lua
│   └── ...
└── claude-code/        # Claude Code settings
    └── settings.json
```

## Post-Installation

### Neovim
- Open nvim and run `:Lazy sync` (if using lazy.nvim)
- Install LSP servers as needed

### Tmux
- Start tmux
- Press `prefix + I` to install plugins (if using TPM)

### Shell PATH
Add this to your `~/.zshrc` if ~/.bin is not in your PATH:
```bash
export PATH="$HOME/.bin:$PATH"
```

## Updating

To update your dotfiles:

```bash
cd ~/.dotfiles
git pull
```

Since configs are symlinked, changes take effect immediately.

## Making Changes

Edit files in `~/.dotfiles/` and commit changes:

```bash
cd ~/.dotfiles
# Make your changes
git add .
git commit -m "Update config"
git push
```

## Notes

- Sensitive files like API keys are excluded from this repo
- The install script backs up existing configs before creating symlinks
- Safe to run install.sh multiple times (it's idempotent)
