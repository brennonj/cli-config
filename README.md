# CLI Config

Personal development environment configuration for macOS.

## What's Included

- **devopen** - Custom script for opening projects in tmux/nvim
- **tmux** - Terminal multiplexer configuration
- **neovim** - Text editor configuration
- **Claude Code** - AI-powered coding assistant settings

## Quick Start

```bash
# Clone the repository
git clone https://github.com/brennonj/cli-config.git ~/.dotfiles

# Run the installation script
cd ~/.dotfiles
./install.sh
```

The install script will:
- Create symlinks from this repo to the appropriate locations
- Backup any existing configs with timestamps
- Set up necessary directories
- Make scripts executable

## Manual Installation

If you prefer to set things up manually:

```bash
# Link configs
ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/nvim ~/.config/nvim
ln -sf ~/.dotfiles/scripts/devopen ~/bin/devopen
ln -sf ~/.dotfiles/claude-code/settings.json ~/.claude/settings.json

# Make scripts executable
chmod +x ~/bin/devopen

# Ensure ~/bin is in PATH
export PATH="$HOME/bin:$PATH"
```

## Structure

```
.dotfiles/
├── install.sh           # Installation script
├── scripts/
│   └── devopen         # Project opener script
├── tmux/
│   └── .tmux.conf      # Tmux configuration
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
Add this to your `~/.bashrc` or `~/.zshrc` if ~/bin is not in your PATH:
```bash
export PATH="$HOME/bin:$PATH"
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
