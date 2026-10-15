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

# Git prompt configuration
set -g __fish_git_prompt_status_order stagedstate invalidstate dirtystate untrackedfiles stashstate
set -g __fish_git_prompt_showstaged yes
set -g __fish_git_prompt_showdirtystate yes
set -g __fish_git_prompt_showuntrackedfiles yes
set -g __fish_git_prompt_showstashstate yes
set -g __fish_git_prompt_showupstream none
set -g __fish_git_prompt_show_informative_status no

# Git symbols - clean repo shows just branch name, stash uses *
set -g __fish_git_prompt_char_stagedstate '+'
set -g __fish_git_prompt_char_dirtystate '!'
set -g __fish_git_prompt_char_untrackedfiles '?'
set -g __fish_git_prompt_char_stashstate '*'
set -g __fish_git_prompt_char_cleanstate ''
