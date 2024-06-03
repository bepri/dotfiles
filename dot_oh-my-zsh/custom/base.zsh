# Set some useful options
setopt nohup            # Don't kill jobs when the shell exits
setopt nobeep           # Don't beep at me all the time
setopt nocheckjobs      # Don't check for running jobs at shell exit
setopt longlistjobs     # Show more information about jobs
setopt pushdtohome      # pushd goes to $HOME if nothing else is given
setopt noflowcontrol    # Disables ^S/^Q in line-edit mode
setopt correct          # Enables name correction suggestions

unsetopt HIST_VERIFY

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

alias reflect="sudo reflector --verbose --country 'United States' -l 5 --sort rate --save /etc/pacman.d/mirrorlist"
