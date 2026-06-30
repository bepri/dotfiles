#!/usr/bin/env fish

# Just always install this early
sudo apt install build-essential -y

# cargo
if not command -q cargo
    if command -q snap
        sudo snap install rustup --classic
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -- -y --no-modify-path
    end

    rustup install stable
end

# pnpm
if not command -q pnpm
    sudo apt install libatomic1 -y
    curl -fsSL https://get.pnpm.io/install.sh | sh
    # Restore config from pnpm setup
    # https://github.com/pnpm/get.pnpm.io/issues/37
    chezmoi apply ~/.config/fish/config.fish
end


cargo install --locked bat

# Parallel arrays: apt package name -> cargo crate (empty = no fallback)
set -l apt_packages  git-delta  ripgrep   fd-find
set -l cargo_crates  git-delta  ripgrep   fd-find

set -l apt_to_install
set -l cargo_to_install

for i in (seq (count $apt_packages))
    if apt-cache show $apt_packages[$i] &>/dev/null
        set -a apt_to_install $apt_packages[$i]
    else if test -n "$cargo_crates[$i]"
        echo "⚠ apt package not found, will use cargo: $apt_packages[$i]"
        set -a cargo_to_install $cargo_crates[$i]
    else
        echo "⚠ apt package not found, no fallback available: $apt_packages[$i]"
    end
end

if test (count $apt_to_install) -gt 0
    echo "fetching via apt: $apt_to_install"
    sudo apt install -y $apt_to_install
end

if test (count $cargo_to_install) -gt 0
    echo "fetching via cargo: $cargo_to_install"
    for crate in $cargo_to_install
        cargo install -q $crate
    end
end

# Configure fish plugins
if not functions -q fisher
    echo "Installing fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher update < ~/.config/fish/fish_plugins
end
