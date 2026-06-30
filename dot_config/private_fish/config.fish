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

###################
# Bespoke section #
###################
#
# This area of the config is for one-off configuration scriptlets that aren't so modular that they
# can be abstracted with the help of the "easy" section above, but aren't so complex that they
# should be buried under the "read-only" section

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
