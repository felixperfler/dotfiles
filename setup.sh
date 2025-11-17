#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%s)"

echo "Setting up dotfiles from $DOTFILES_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to safely create symlink
symlink_file() {
    local src="$1"
    local dest="$2"

    # If destination exists and is not a symlink, back it up
    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ -L "$dest" ]]; then
            # Already a symlink, check if it points to the right place
            local link_target=$(readlink "$dest")
            if [[ "$link_target" == "$src" ]]; then
                echo "✓ Already linked: $dest"
                return 0
            fi
        fi
        # Backup existing file
        mkdir -p "$(dirname "$BACKUP_DIR/${dest#$HOME/}")"
        mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
        echo "→ Backed up: $dest"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Create symlink
    ln -s "$src" "$dest"
    echo "✓ Linked: $dest"
}

# Zsh configs
symlink_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
symlink_file "$DOTFILES_DIR/zsh/.profile" "$HOME/.profile"

# Git configs
symlink_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
mkdir -p "$HOME/.config/git"
symlink_file "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore"

# Helix configs
mkdir -p "$HOME/.config/helix"
symlink_file "$DOTFILES_DIR/helix/config.toml" "$HOME/.config/helix/config.toml"
symlink_file "$DOTFILES_DIR/helix/languages.toml" "$HOME/.config/helix/languages.toml"

# Ghostty configs
mkdir -p "$HOME/.config/ghostty"
symlink_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
symlink_file "$DOTFILES_DIR/ghostty/themes" "$HOME/.config/ghostty/themes"

# Starship config
symlink_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# Ruff config
mkdir -p "$HOME/.config/ruff"
symlink_file "$DOTFILES_DIR/ruff/ruff.toml" "$HOME/.config/ruff/ruff.toml"

# Claude Code config
mkdir -p "$HOME/.claude"
symlink_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# SSH config
mkdir -p "$HOME/.ssh"
symlink_file "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"

# Custom scripts
mkdir -p "$HOME/.local/bin"
symlink_file "$DOTFILES_DIR/scripts/env" "$HOME/.local/bin/env"
symlink_file "$DOTFILES_DIR/scripts/sync-helix-ghostty-theme" "$HOME/.local/bin/sync-helix-ghostty-theme"
chmod +x "$HOME/.local/bin/env"
chmod +x "$HOME/.local/bin/sync-helix-ghostty-theme"

echo ""
echo "✓ Dotfiles setup complete!"
if [[ -d "$BACKUP_DIR" && -n "$(ls -A "$BACKUP_DIR")" ]]; then
    echo "Backups saved to: $BACKUP_DIR"
fi
