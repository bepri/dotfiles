######################
# Easy edits section #
######################
#
# This area of the config is for simple definitions that get handled later, like path extensions.

set -gx PNPM_HOME ~/.local/share/pnpm

# List of paths to add to the PATH if they exist on the machine.
set -l extra_paths \
    ~/.cargo/bin   \
    ~/work/bin     \
    ~/go/bin       \
    "$PNPM_HOME/bin"

#####################
# Read-only section #
#####################
#
# Not genuinely "read-only", but this section holds functionality that _most likely_ doesn't need
# inspection or editing very often.

# PATH configuration
for dir in $extra_paths
    fish_add_path $dir
end
set -e extra_paths

set -Ux EDITOR "zed -w"
set -Ux VISUAL "$EDITOR"
set -Ux SUDO_EDITOR "$EDITOR"
set -Ux VIRTUAL_ENV_DISABLE_PROMPT true

# Silence!
set -U fish_greeting ""

if systemd-detect-virt -cq 2>/dev/null
    set -g tide_pwd_color_dirs 8787AF
    set -g tide_pwd_color_anchors AF87FF
    set -g tide_pwd_color_truncated_dirs 5F5F87
end
