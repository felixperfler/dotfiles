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

# Helper function to extract version from GitHub API response
get_github_version() {
    local repo=$1
    curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -m1 '"tag_name"' | cut -d'"' -f4
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
    set +e
    curl -LsSf https://astral.sh/uv/install.sh | sh
    if [[ -f "$HOME/.cargo/env" ]]; then
        source $HOME/.cargo/env
    fi
    set -e
fi

# ===== Bun =====
if command_exists bun; then
    echo -e "${GREEN}✓${NC} Bun already installed"
else
    echo -e "${BLUE}→${NC} Installing Bun..."
    set +e
    curl -fsSL https://bun.sh/install | bash
    set -e
fi

# ===== Helix =====
if command_exists hx; then
    echo -e "${GREEN}✓${NC} Helix already installed"
else
    echo -e "${BLUE}→${NC} Installing Helix..."
    HELIX_VERSION=$(get_github_version "helix-editor/helix")

    if [[ -z "$HELIX_VERSION" ]]; then
        echo -e "${RED}ERROR: Could not determine Helix version. GitHub API may be rate limited or unavailable.${NC}"
        exit 1
    fi

    echo "  Downloading Helix $HELIX_VERSION..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - determine architecture
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            HELIX_ARCH="aarch64"
        else
            HELIX_ARCH="x86_64"
        fi
        curl -L "https://github.com/helix-editor/helix/releases/download/$HELIX_VERSION/helix-$HELIX_VERSION-${HELIX_ARCH}-macos.tar.xz" -o /tmp/helix.tar.xz 2>/dev/null
        if ! tar -tf /tmp/helix.tar.xz &>/dev/null; then
            echo -e "${RED}ERROR: Failed to download Helix. The release file may not exist.${NC}"
            rm -f /tmp/helix.tar.xz
            exit 1
        fi
        mkdir -p /tmp/helix
        tar -xf /tmp/helix.tar.xz -C /tmp/helix
        if [[ -f "/tmp/helix/helix-$HELIX_VERSION-${HELIX_ARCH}-macos/hx" ]]; then
            mv /tmp/helix/helix-$HELIX_VERSION-${HELIX_ARCH}-macos/hx ~/.local/bin/
            chmod +x ~/.local/bin/hx
            # Extract runtime directory
            mkdir -p ~/.config/helix
            cp -r /tmp/helix/helix-$HELIX_VERSION-${HELIX_ARCH}-macos/runtime ~/.config/helix/
        else
            echo -e "${RED}ERROR: Could not find helix binary in archive${NC}"
            rm -rf /tmp/helix /tmp/helix.tar.xz
            exit 1
        fi
        rm -rf /tmp/helix /tmp/helix.tar.xz
    else
        # Linux
        ARCH=$(uname -m)
        curl -L "https://github.com/helix-editor/helix/releases/download/$HELIX_VERSION/helix-$HELIX_VERSION-${ARCH}-linux.tar.xz" -o /tmp/helix.tar.xz 2>/dev/null
        if ! tar -tf /tmp/helix.tar.xz &>/dev/null; then
            echo -e "${RED}ERROR: Failed to download Helix. The release file may not exist.${NC}"
            rm -f /tmp/helix.tar.xz
            exit 1
        fi
        mkdir -p /tmp/helix
        tar -xf /tmp/helix.tar.xz -C /tmp/helix
        if [[ -f "/tmp/helix/helix-$HELIX_VERSION-${ARCH}-linux/hx" ]]; then
            mv /tmp/helix/helix-$HELIX_VERSION-${ARCH}-linux/hx ~/.local/bin/
            chmod +x ~/.local/bin/hx
            # Extract runtime directory
            mkdir -p ~/.config/helix
            cp -r /tmp/helix/helix-$HELIX_VERSION-${ARCH}-linux/runtime ~/.config/helix/
        else
            echo -e "${RED}ERROR: Could not find helix binary in archive${NC}"
            rm -rf /tmp/helix /tmp/helix.tar.xz
            exit 1
        fi
        rm -rf /tmp/helix /tmp/helix.tar.xz
    fi
fi

# ===== Starship =====
if command_exists starship; then
    echo -e "${GREEN}✓${NC} Starship already installed"
else
    echo -e "${BLUE}→${NC} Installing Starship..."
    set +e
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin
    set -e
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
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            TECTONIC_ARCH="aarch64-apple-darwin"
        else
            TECTONIC_ARCH="x86_64-apple-darwin"
        fi
        TECTONIC_URL=$(curl -s "https://api.github.com/repos/tectonic-typesetting/tectonic/releases/latest" | grep "browser_download_url.*$TECTONIC_ARCH.tar.gz" | cut -d'"' -f4)
    else
        # Linux
        ARCH=$(uname -m)
        if [[ "$ARCH" == "x86_64" ]]; then
            TECTONIC_ARCH="x86_64-unknown-linux-musl"
        else
            TECTONIC_ARCH="aarch64-unknown-linux-musl"
        fi
        TECTONIC_URL=$(curl -s "https://api.github.com/repos/tectonic-typesetting/tectonic/releases/latest" | grep "browser_download_url.*$TECTONIC_ARCH.tar.gz" | cut -d'"' -f4)
    fi

    if [[ -z "$TECTONIC_URL" ]]; then
        echo -e "${RED}ERROR: Could not find Tectonic release for this architecture.${NC}"
        exit 1
    fi

    echo "  Downloading Tectonic..."
    curl -L "$TECTONIC_URL" -o /tmp/tectonic.tar.gz 2>/dev/null
    if ! tar -tf /tmp/tectonic.tar.gz &>/dev/null; then
        echo -e "${RED}ERROR: Failed to download or verify Tectonic archive.${NC}"
        rm -f /tmp/tectonic.tar.gz
        exit 1
    fi
    tar -xf /tmp/tectonic.tar.gz -C ~/.local/bin/
    chmod +x ~/.local/bin/tectonic 2>/dev/null || true
    rm /tmp/tectonic.tar.gz
fi

# ===== GitHub CLI =====
if command_exists gh; then
    echo -e "${GREEN}✓${NC} GitHub CLI already installed"
else
    echo -e "${BLUE}→${NC} Installing GitHub CLI..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            GH_PATTERN="macOS_arm64.zip"
        else
            GH_PATTERN="macOS_amd64.zip"
        fi
        GH_URL=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep "browser_download_url.*${GH_PATTERN}" | cut -d'"' -f4)
        if [[ -z "$GH_URL" ]]; then
            echo -e "${RED}ERROR: Could not find GitHub CLI release for macOS.${NC}"
            exit 1
        fi
        echo "  Downloading GitHub CLI..."
        curl -L "$GH_URL" -o /tmp/gh.zip 2>/dev/null
        if ! unzip -t /tmp/gh.zip &>/dev/null; then
            echo -e "${RED}ERROR: Failed to download or verify GitHub CLI archive.${NC}"
            rm -f /tmp/gh.zip
            exit 1
        fi
        mkdir -p /tmp/gh
        unzip -q /tmp/gh.zip -d /tmp/gh
        GH_BIN=$(find /tmp/gh -name "gh" -type f | head -1)
        if [[ -f "$GH_BIN" ]]; then
            mv "$GH_BIN" ~/.local/bin/
            chmod +x ~/.local/bin/gh
        else
            echo -e "${RED}ERROR: Could not find gh binary in archive${NC}"
            rm -rf /tmp/gh /tmp/gh.zip
            exit 1
        fi
        rm -rf /tmp/gh /tmp/gh.zip
    else
        # Linux
        ARCH=$(uname -m)
        if [[ "$ARCH" == "x86_64" ]]; then
            GH_PATTERN="linux_amd64.tar.gz"
        elif [[ "$ARCH" == "aarch64" ]]; then
            GH_PATTERN="linux_arm64.tar.gz"
        else
            GH_PATTERN="linux_${ARCH}.tar.gz"
        fi
        GH_URL=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep "browser_download_url.*${GH_PATTERN}" | cut -d'"' -f4 | head -1)
        if [[ -z "$GH_URL" ]]; then
            echo -e "${RED}ERROR: Could not find GitHub CLI release for $ARCH.${NC}"
            exit 1
        fi
        echo "  Downloading GitHub CLI..."
        curl -L "$GH_URL" -o /tmp/gh.tar.gz 2>/dev/null
        if ! tar -tf /tmp/gh.tar.gz &>/dev/null; then
            echo -e "${RED}ERROR: Failed to download or verify GitHub CLI archive.${NC}"
            rm -f /tmp/gh.tar.gz
            exit 1
        fi
        mkdir -p /tmp/gh
        tar -xf /tmp/gh.tar.gz -C /tmp/gh
        GH_BIN=$(find /tmp/gh -name "gh" -type f | head -1)
        if [[ -f "$GH_BIN" ]]; then
            mv "$GH_BIN" ~/.local/bin/
            chmod +x ~/.local/bin/gh
        else
            echo -e "${RED}ERROR: Could not find gh binary in archive${NC}"
            rm -rf /tmp/gh /tmp/gh.tar.gz
            exit 1
        fi
        rm -rf /tmp/gh /tmp/gh.tar.gz
    fi
fi

# ===== Codex CLI =====
if command_exists codex; then
    echo -e "${GREEN}✓${NC} Codex CLI already installed"
else
    echo -e "${BLUE}→${NC} Installing Codex CLI..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            CODEX_ARCH="aarch64"
        else
            CODEX_ARCH="x86_64"
        fi
        echo "  Downloading Codex CLI..."
        CODEX_URL=$(curl -s "https://api.github.com/repos/openai/codex/releases/latest" | sed 's/,/\n/g' | grep "browser_download_url.*codex-${CODEX_ARCH}-apple-darwin.tar.gz" | cut -d'"' -f4)
        if [[ -z "$CODEX_URL" ]]; then
            echo -e "${RED}ERROR: Could not find Codex release for this architecture.${NC}"
            exit 1
        fi
        curl -L "$CODEX_URL" -o /tmp/codex.tar.gz 2>/dev/null
        if ! tar -tf /tmp/codex.tar.gz &>/dev/null; then
            echo -e "${RED}ERROR: Failed to download Codex CLI. The release file may not exist.${NC}"
            rm -f /tmp/codex.tar.gz
            exit 1
        fi
        mkdir -p /tmp/codex
        tar -xf /tmp/codex.tar.gz -C /tmp/codex
        if [[ -f "/tmp/codex/codex-${CODEX_ARCH}-apple-darwin" ]]; then
            mv "/tmp/codex/codex-${CODEX_ARCH}-apple-darwin" ~/.local/bin/codex
            chmod +x ~/.local/bin/codex
        else
            echo -e "${RED}ERROR: Could not find codex binary in archive${NC}"
            rm -rf /tmp/codex /tmp/codex.tar.gz
            exit 1
        fi
        rm -rf /tmp/codex /tmp/codex.tar.gz
    else
        echo -e "${RED}ERROR: Codex CLI is only supported on macOS${NC}"
        exit 1
    fi
fi

# ===== Claude Code =====
if command_exists claude; then
    echo -e "${GREEN}✓${NC} Claude Code already installed"
else
    echo -e "${BLUE}→${NC} Installing Claude Code..."
    set +e
    curl -fsSL https://claude.ai/install.sh | bash
    set -e
fi

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Run ~/.dotfiles/setup.sh to symlink configs"
echo "  2. Install Ghostty manually from: https://github.com/ghostty-org/ghostty/releases"
echo "  3. Close and reopen your terminal for all changes to take effect"
