function slopshell
    lxc exec --user 1001 --cwd "$PWD" \
        --env HOME=/home/imani        \
        --env USER=imani              \
        --env LOGNAME=imani           \
        --env SHELL=/bin/bash         \
        --env PATH="$PATH"            \
        opencode -- /bin/bash -l
end
