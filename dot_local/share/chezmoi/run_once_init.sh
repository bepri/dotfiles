#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt upgrade -y

if ! command -v fish &>/dev/null; then
    if ! apt-cache show fish &>/dev/null; then
        echo "fish not found in current repos, adding PPA..."
        sudo add-apt-repository -y ppa:fish-shell/release-4
        sudo apt update
    fi
    sudo apt install -y fish
fi

if [ "$SHELL" != "$(which fish)" ]; then
    chsh -s "$(which fish)"
fi
