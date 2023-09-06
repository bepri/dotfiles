# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export LPASS_AGENT_TIMEOUT=43200

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Don't have the shell check for mail
unset MAIL

# Get other shell configuration
source $HOME/.zsh.aliases                           # setup command aliases
source $HOME/powerlevel10k/powerlevel10k.zsh-theme  # ???

bindkey -d

umask 077

# Turn off core dumps
limit coredumpsize 0

# Set some usefull options
setopt nohup            # Don't kill jobs when the shell exits
setopt nobeep           # Don't beep at me all the time
setopt nocheckjobs      # Don't check for running jobs at shell exit
setopt longlistjobs     # Show more information about jobs
setopt pushdtohome      # pushd goes to $HOME if nothing else is given
setopt noflowcontrol    # Disables ^S/^Q in line-edit mode
setopt correct          # Enables name correction suggestions


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
