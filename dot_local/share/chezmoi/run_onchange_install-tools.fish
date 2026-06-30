#!/usr/bin/env fish

# Just always install this early
if not dpkg -s build-essential &>/dev/null
    sudo apt install -y build-essential
end

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

# Parallel arrays: apt package name -> cargo crate (empty = no fallback)
set -l apt_packages  git-delta  ripgrep  fd-find  bat
set -l cargo_crates  git-delta  ripgrep  fd-find  bat

set -l apt_to_install
set -l cargo_to_install

for i in (seq (count $apt_packages))
    if dpkg -s $apt_packages[$i] &>/dev/null
        continue
    else if apt-cache show $apt_packages[$i] &>/dev/null
        set -a apt_to_install $apt_packages[$i]
    else if test -n "$cargo_crates[$i]"
        if not command -q $cargo_crates[$i]
            echo "⚠ apt package not found, will use cargo: $apt_packages[$i]"
            set -a cargo_to_install $cargo_crates[$i]
        end
    else
        echo "⚠ apt package not found, no fallback available: $apt_packages[$i]"
    end
end

if test (count $apt_to_install) -gt 0
    echo "fetching via apt: $apt_to_install"
    sudo apt install -y $apt_to_install
end

if test (count $cargo_to_install) -gt 0
    if test -f ~/.config/.no-cargo
        echo "skipping cargo installs, found ~/.config/.no-cargo"
    else
        echo "fetching via cargo: $cargo_to_install"
        for crate in $cargo_to_install
            cargo install -q $crate
        end
    end
end

# Install tide (from tide's manual install instructions)
if not functions -q tide
    set -l _tide_tmp_dir (command mktemp -d)
    curl https://codeload.github.com/ilancosman/tide/tar.gz/v6 | tar -xzC $_tide_tmp_dir
    command cp -R $_tide_tmp_dir/*/{completions,conf.d,functions} $__fish_config_dir
    fish -c "emit _tide_init_install"
    set -e _tide_tmp_dir
    # Forcefully load tide for this line
    source $__fish_config_dir/functions/tide.fish
    tide configure --auto \
		--style=Classic \
		--prompt_colors='True color' \
		--classic_prompt_color=Dark \
		--show_time='24-hour format' \
		--classic_prompt_separators=Round \
		--powerline_prompt_heads=Round \
		--powerline_prompt_tails=Round \
		--powerline_prompt_style='Two lines, character and frame' \
		--prompt_connection=Solid \
		--powerline_right_prompt_frame=No \
		--prompt_connection_andor_frame_color=Dark \
		--prompt_spacing=Sparse \
		--icons='Many icons' \
		--transient=No
end

# Configure fish plugins
if not functions -q fisher
    # Set up ssh directory so the ssh_agent_plugin doesn't scream
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "Installing fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
    fisher update < ~/.config/fish/fish_plugins
end
