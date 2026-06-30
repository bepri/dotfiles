#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt upgrade -y

if ! command -v fish &>/dev/null; then
    sudo apt install -y fish
fi

if [ "$SHELL" != "$(which fish)" ]; then
    chsh -s "$(which fish)"
fi
