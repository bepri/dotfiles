if file -f $HOME/.cargo/bin/bat
    alias cat $HOME/.cargo/bin/bat
else if command -q batcat
    alias cat $(which batcat)
end

alias fd /usr/bin/fdfind
