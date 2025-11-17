# Dotfiles

My personal dotfiles repository for quick setup on new machines.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles ~/.dotfiles

# Run the installation script (installs most tools)
~/.dotfiles/install.sh

# Symlink all configuration files
~/.dotfiles/setup.sh

# Install manual dependencies (not automated)
bun install -g @anthropic-ai/claude-code    # or: npm install -g @anthropic-ai/claude-code
# Install Ghostty from: https://github.com/ghostty-org/ghostty/releases
```

## What's Included

### Tools Installed by `install.sh`

- **uv** - Fast Python package manager and project manager
- **Bun** - Fast JavaScript runtime and package manager
- **Helix** - Modern text editor written in Rust
- **Starship** - Fast, customizable shell prompt
- **Ruff** - Python linter and formatter (via uv)
- **Ty** - Python type checker (via uv)
- **Tectonic** - Typesetting system (LaTeX alternative)
- **GitHub CLI** - Command-line interface for GitHub

### Configuration Files

- **zsh** - Shell configuration (.zshrc, .profile)
- **git** - Git configuration and global gitignore
- **helix** - Editor config and language server settings
- **ghostty** - Terminal emulator config and Modus themes
- **starship** - Prompt configuration
- **ruff** - Python linter rules
- **claude** - Claude Code settings (model, thinking enabled)
- **ssh** - SSH configuration for hosts
- **scripts** - Custom utility scripts

### Not Automated

- **Ghostty** - Must be installed manually from [releases](https://github.com/ghostty-org/ghostty/releases)
  - Configuration will be symlinked by `setup.sh`
- **Claude Code** - Install via bun or npm:
  ```bash
  bun install -g @anthropic-ai/claude-code
  # or
  npm install -g @anthropic-ai/claude-code
  ```

## Directory Structure

```
~/.dotfiles/
├── setup.sh                    # Symlink configuration files
├── install.sh                  # Install all tools
├── README.md                   # This file
├── .gitignore
├── zsh/
│   ├── .zshrc
│   └── .profile
├── git/
│   ├── .gitconfig
│   └── ignore
├── helix/
│   ├── config.toml
│   └── languages.toml
├── ghostty/
│   ├── config
│   └── themes/                 # Modus theme files
├── starship/
│   └── starship.toml
├── ruff/
│   └── ruff.toml
├── claude/
│   └── settings.json
├── ssh/
│   └── config
└── scripts/
    ├── env                     # PATH setup
    └── sync-helix-ghostty-theme  # Theme synchronization
```

## Configuration Details

### Shell Setup

- Uses **Zsh** with Starship prompt
- Includes Python venv auto-activation
- Helix/Ghostty theme synchronization on startup
- Bun completions and PATH configuration

### Editor (Helix)

- Theme: Modus Vivendi (dark mode)
- Relative line numbers
- Auto-save enabled
- Soft-wrap enabled
- LSP with inlay hints configured
- Python: using Ruff and type checkers
- MATLAB language server support

### Terminal (Ghostty)

- Includes 8 custom Modus themes:
  - `modus-operandi` (light)
  - `modus-vivendi` (dark)
  - Accessibility variants (deuteranopia, tritanopia, tinted)
- Font and keybinding configurations

### Python Development

- **Ruff** for linting and formatting
- **Ty** for type checking
- **uv** for package management

## Scripts

### `sync-helix-ghostty-theme`

Keeps Helix and Ghostty themes in sync. Called automatically on shell startup.

### `env`

Sets up custom PATH and environment variables.

## Customization

### Adding/Updating Configs

1. Update the config file in `~/.config/` or `~/.`
2. Copy the updated file to the appropriate location in `~/.dotfiles/`
3. Run `~/.dotfiles/setup.sh` to verify symlinks
4. Commit changes to git

### Machine-Specific Overrides

If you need machine-specific settings:

1. Create a `~/.config/local/` directory (not tracked)
2. Source local overrides in config files:
   ```bash
   # In ~/.zshrc
   [[ -f ~/.config/local/zshrc ]] && source ~/.config/local/zshrc
   ```

## Platform Support

Tested on:
- macOS (Apple Silicon and Intel)
- Linux (x86_64)

Installation scripts auto-detect your OS and download appropriate binaries.

## Troubleshooting

### Tools not in PATH

After running install scripts, you may need to restart your terminal or run:
```bash
source ~/.zshrc
```

### SSH Config Permissions

SSH requires strict permissions. After setup, verify:
```bash
chmod 600 ~/.ssh/config
chmod 700 ~/.ssh
```

### Symlink Issues

If symlinks aren't created correctly, check:
```bash
# View symlink status
ls -la ~/.zshrc
ls -la ~/.config/helix/

# Re-run setup to fix
~/.dotfiles/setup.sh
```

## License

These are my personal dotfiles. Feel free to fork and customize for your own setup!
