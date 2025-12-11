#!/bin/bash

set -e

echo "Updating tools from dotfiles setup..."

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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
    echo -e "${BLUE}→${NC} Updating uv..."
    uv self update
    echo -e "${GREEN}✓${NC} uv updated"
else
    echo -e "${RED}✗${NC} uv not found, please run install.sh first"
fi

# ===== Helix =====
if command_exists hx; then
    echo -e "${BLUE}→${NC} Updating Helix..."
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
            # Update runtime directory
            rm -rf ~/.config/helix/runtime
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
            # Update runtime directory
            rm -rf ~/.config/helix/runtime
            mkdir -p ~/.config/helix
            cp -r /tmp/helix/helix-$HELIX_VERSION-${ARCH}-linux/runtime ~/.config/helix/
        else
            echo -e "${RED}ERROR: Could not find helix binary in archive${NC}"
            rm -rf /tmp/helix /tmp/helix.tar.xz
            exit 1
        fi
        rm -rf /tmp/helix /tmp/helix.tar.xz
    fi
    echo -e "${GREEN}✓${NC} Helix updated"
else
    echo -e "${RED}✗${NC} Helix not found, please run install.sh first"
fi

# ===== Starship =====
if command_exists starship; then
    echo -e "${BLUE}→${NC} Updating Starship..."
    set +e
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir ~/.local/bin
    set -e
    echo -e "${GREEN}✓${NC} Starship updated"
else
    echo -e "${RED}✗${NC} Starship not found, please run install.sh first"
fi

# ===== Glow =====
if command_exists glow; then
    echo -e "${BLUE}→${NC} Updating Glow..."
    GLOW_VERSION=$(get_github_version "charmbracelet/glow")

    if [[ -z "$GLOW_VERSION" ]]; then
        echo -e "${RED}ERROR: Could not determine Glow version. GitHub API may be rate limited or unavailable.${NC}"
        exit 1
    fi

    GLOW_VERSION_CLEAN=${GLOW_VERSION#v}

    if [[ "$OSTYPE" == "darwin"* ]]; then
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            GLOW_ARCH="Darwin_arm64"
        else
            GLOW_ARCH="Darwin_x86_64"
        fi
    else
        ARCH=$(uname -m)
        if [[ "$ARCH" == "aarch64" ]]; then
            GLOW_ARCH="Linux_arm64"
        else
            GLOW_ARCH="Linux_x86_64"
        fi
    fi

    GLOW_URL="https://github.com/charmbracelet/glow/releases/download/$GLOW_VERSION/glow_${GLOW_VERSION_CLEAN}_${GLOW_ARCH}.tar.gz"

    echo "  Downloading Glow $GLOW_VERSION..."
    curl -L "$GLOW_URL" -o /tmp/glow.tar.gz 2>/dev/null
    if ! tar -tf /tmp/glow.tar.gz &>/dev/null; then
        echo -e "${RED}ERROR: Failed to download or verify Glow archive.${NC}"
        rm -f /tmp/glow.tar.gz
        exit 1
    fi
    mkdir -p /tmp/glow
    tar -xf /tmp/glow.tar.gz -C /tmp/glow
    GLOW_BIN=$(find /tmp/glow -name "glow" -type f | head -1)
    if [[ -f "$GLOW_BIN" ]]; then
        mv "$GLOW_BIN" ~/.local/bin/
        chmod +x ~/.local/bin/glow
    else
        echo -e "${RED}ERROR: Could not find glow binary in archive${NC}"
        rm -rf /tmp/glow /tmp/glow.tar.gz
        exit 1
    fi
    rm -rf /tmp/glow /tmp/glow.tar.gz
    echo -e "${GREEN}✓${NC} Glow updated"
else
    echo -e "${RED}✗${NC} Glow not found, please run install.sh first"
fi

# ===== Ruff (via uv) =====
if command_exists ruff; then
    echo -e "${BLUE}→${NC} Updating Ruff..."
    uv tool upgrade ruff
    echo -e "${GREEN}✓${NC} Ruff updated"
else
    echo -e "${RED}✗${NC} Ruff not found, please run install.sh first"
fi

# ===== Ty (via uv) =====
if command_exists ty; then
    echo -e "${BLUE}→${NC} Updating Ty..."
    uv tool upgrade ty
    echo -e "${GREEN}✓${NC} Ty updated"
else
    echo -e "${RED}✗${NC} Ty not found, please run install.sh first"
fi

# ===== Tectonic =====
if command_exists tectonic; then
    echo -e "${BLUE}→${NC} Updating Tectonic..."
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
    echo -e "${GREEN}✓${NC} Tectonic updated"
else
    echo -e "${RED}✗${NC} Tectonic not found, please run install.sh first"
fi

# ===== Codex CLI =====
if command_exists codex; then
    echo -e "${BLUE}→${NC} Updating Codex CLI..."
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
    echo -e "${GREEN}✓${NC} Codex CLI updated"
else
    echo -e "${RED}✗${NC} Codex CLI not found, please run install.sh first"
fi

echo ""
echo -e "${GREEN}✓ Updates complete!${NC}"
echo ""
