#!/bin/bash

set -e

echo "Installing tools for dotfiles setup..."

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure ~/.local/bin exists and is in PATH
mkdir -p ~/.local/bin
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# ===== uv =====
if command_exists uv; then
    echo -e "${GREEN}✓${NC} uv already installed"
else
    echo -e "${BLUE}→${NC} Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.cargo/env 2>/dev/null || true
fi

# ===== Bun =====
if command_exists bun; then
    echo -e "${GREEN}✓${NC} Bun already installed"
else
    echo -e "${BLUE}→${NC} Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
fi

# ===== Helix =====
if command_exists hx; then
    echo -e "${GREEN}✓${NC} Helix already installed"
else
    echo -e "${BLUE}→${NC} Installing Helix..."
    HELIX_API=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest)
    HELIX_VERSION=$(echo "$HELIX_API" | grep -o '"tag_name":"[^"]*' | cut -d'"' -f4)

    if [[ -z "$HELIX_VERSION" ]]; then
        echo "ERROR: Could not determine Helix version. GitHub API may be rate limited or unavailable."
        return 1
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        curl -L "https://github.com/helix-editor/helix/releases/download/$HELIX_VERSION/helix-$HELIX_VERSION-macos-universal.tar.xz" -o /tmp/helix.tar.xz 2>/dev/null
        if ! tar -tf /tmp/helix.tar.xz &>/dev/null; then
            echo "ERROR: Failed to download Helix. The release file may not exist."
            rm -f /tmp/helix.tar.xz
            return 1
        fi
        mkdir -p /tmp/helix
        tar -xf /tmp/helix.tar.xz -C /tmp/helix
        mv /tmp/helix/helix-$HELIX_VERSION-macos-universal/hx ~/.local/bin/
        rm -rf /tmp/helix /tmp/helix.tar.xz
    else
        # Linux
        ARCH=$(uname -m)
        curl -L "https://github.com/helix-editor/helix/releases/download/$HELIX_VERSION/helix-$HELIX_VERSION-linux-$ARCH.tar.xz" -o /tmp/helix.tar.xz 2>/dev/null
        if ! tar -tf /tmp/helix.tar.xz &>/dev/null; then
            echo "ERROR: Failed to download Helix. The release file may not exist."
            rm -f /tmp/helix.tar.xz
            return 1
        fi
        mkdir -p /tmp/helix
        tar -xf /tmp/helix.tar.xz -C /tmp/helix
        mv /tmp/helix/helix-$HELIX_VERSION-linux-$ARCH/hx ~/.local/bin/
        rm -rf /tmp/helix /tmp/helix.tar.xz
    fi
fi

# ===== Starship =====
if command_exists starship; then
    echo -e "${GREEN}✓${NC} Starship already installed"
else
    echo -e "${BLUE}→${NC} Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin
fi

# ===== Ruff (via uv) =====
if command_exists ruff; then
    echo -e "${GREEN}✓${NC} Ruff already installed"
else
    echo -e "${BLUE}→${NC} Installing Ruff via uv..."
    uv tool install ruff --python 3.12
fi

# ===== Ty (via uv) =====
if command_exists ty; then
    echo -e "${GREEN}✓${NC} Ty already installed"
else
    echo -e "${BLUE}→${NC} Installing Ty via uv..."
    uv tool install ty --python 3.12
fi

# ===== Tectonic =====
if command_exists tectonic; then
    echo -e "${GREEN}✓${NC} Tectonic already installed"
else
    echo -e "${BLUE}→${NC} Installing Tectonic..."
    TECTONIC_API=$(curl -s https://api.github.com/repos/tectonic-typesetting/tectonic/releases/latest)
    TECTONIC_VERSION=$(echo "$TECTONIC_API" | grep -o '"tag_name":"[^"]*' | cut -d'"' -f4)

    if [[ -z "$TECTONIC_VERSION" ]]; then
        echo "ERROR: Could not determine Tectonic version. GitHub API may be rate limited or unavailable."
        return 1
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        curl -L "https://github.com/tectonic-typesetting/tectonic/releases/download/$TECTONIC_VERSION/tectonic-$TECTONIC_VERSION-macos.tar.gz" -o /tmp/tectonic.tar.gz 2>/dev/null
        if ! tar -tf /tmp/tectonic.tar.gz &>/dev/null; then
            echo "ERROR: Failed to download Tectonic. The release file may not exist."
            rm -f /tmp/tectonic.tar.gz
            return 1
        fi
        tar -xf /tmp/tectonic.tar.gz -C ~/.local/bin/
        rm /tmp/tectonic.tar.gz
    else
        # Linux
        ARCH=$(uname -m)
        curl -L "https://github.com/tectonic-typesetting/tectonic/releases/download/$TECTONIC_VERSION/tectonic-$TECTONIC_VERSION-linux-$ARCH.tar.gz" -o /tmp/tectonic.tar.gz 2>/dev/null
        if ! tar -tf /tmp/tectonic.tar.gz &>/dev/null; then
            echo "ERROR: Failed to download Tectonic. The release file may not exist."
            rm -f /tmp/tectonic.tar.gz
            return 1
        fi
        tar -xf /tmp/tectonic.tar.gz -C ~/.local/bin/
        rm /tmp/tectonic.tar.gz
    fi
fi

# ===== GitHub CLI =====
if command_exists gh; then
    echo -e "${GREEN}✓${NC} GitHub CLI already installed"
else
    echo -e "${BLUE}→${NC} Installing GitHub CLI..."
    GH_API=$(curl -s https://api.github.com/repos/cli/cli/releases/latest)
    GH_VERSION=$(echo "$GH_API" | grep -o '"tag_name":"[^"]*' | cut -d'"' -f4 | cut -dv -f2)

    if [[ -z "$GH_VERSION" ]]; then
        echo "ERROR: Could not determine GitHub CLI version. GitHub API may be rate limited or unavailable."
        return 1
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        curl -L "https://github.com/cli/cli/releases/download/v$GH_VERSION/gh_${GH_VERSION}_macOS_universal.tar.gz" -o /tmp/gh.tar.gz 2>/dev/null
        if ! tar -tf /tmp/gh.tar.gz &>/dev/null; then
            echo "ERROR: Failed to download GitHub CLI. The release file may not exist."
            rm -f /tmp/gh.tar.gz
            return 1
        fi
        mkdir -p /tmp/gh
        tar -xf /tmp/gh.tar.gz -C /tmp/gh
        mv /tmp/gh/gh_${GH_VERSION}_macOS_universal/bin/gh ~/.local/bin/
        rm -rf /tmp/gh /tmp/gh.tar.gz
    else
        # Linux
        ARCH=$(uname -m)
        curl -L "https://github.com/cli/cli/releases/download/v$GH_VERSION/gh_${GH_VERSION}_linux_$ARCH.tar.gz" -o /tmp/gh.tar.gz 2>/dev/null
        if ! tar -tf /tmp/gh.tar.gz &>/dev/null; then
            echo "ERROR: Failed to download GitHub CLI. The release file may not exist."
            rm -f /tmp/gh.tar.gz
            return 1
        fi
        mkdir -p /tmp/gh
        tar -xf /tmp/gh.tar.gz -C /tmp/gh
        mv /tmp/gh/gh_${GH_VERSION}_linux_$ARCH/bin/gh ~/.local/bin/
        rm -rf /tmp/gh /tmp/gh.tar.gz
    fi
fi

# ===== Claude Code =====
if command_exists claude; then
    echo -e "${GREEN}✓${NC} Claude Code already installed"
else
    echo -e "${BLUE}→${NC} Installing Claude Code..."
    curl -L https://github.com/anthropics/claude-code/releases/download/latest/claude-code.tar.gz -o /tmp/claude-code.tar.gz 2>/dev/null
    if ! tar -tf /tmp/claude-code.tar.gz &>/dev/null; then
        echo "ERROR: Failed to download Claude Code. GitHub releases may be unavailable."
        rm -f /tmp/claude-code.tar.gz
        return 1
    fi
    tar -xf /tmp/claude-code.tar.gz -C ~/.local/bin/
    rm /tmp/claude-code.tar.gz
    # Make sure it's executable
    chmod +x ~/.local/bin/claude 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Run ~/.dotfiles/setup.sh to symlink configs"
echo "  2. Install Ghostty manually from: https://github.com/ghostty-org/ghostty/releases"
echo "  3. Close and reopen your terminal for all changes to take effect"
