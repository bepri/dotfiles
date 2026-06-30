function sloperate
    lxc exec --user 1001 --cwd "$PWD" \
        --env HOME=/home/imani        \
        --env USER=imani              \
        --env LOGNAME=imani           \
        --env SHELL=/bin/bash         \
        copilot -- gh copilot -- --add-dir "$PWD" $argv
end
