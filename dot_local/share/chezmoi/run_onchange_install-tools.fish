#!/usr/bin/env fish

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
    curl -fsSL https://get.pnpm.io/install.sh | sh
    # Restore config from pnpm setup
    # https://github.com/pnpm/get.pnpm.io/issues/37
    chezmoi apply ~/.config/fish/config.fish
end


cargo install --locked bat

set -l apt_tools \
    git-delta    \
    rg           \
    fd-find

set -l to_install
for pkg in $apt_tools
    if apt-cache show $pkg &>/dev/null
        set -a to_install $pkg
    else
        echo "⚠ Package not found, skipping: $pkg"
    end
end

if test (count $to_install) -gt 0
    echo "fetching: $to_install"
    sudo apt install -y $to_install
end
set -e apt_tools
set -e to_install
