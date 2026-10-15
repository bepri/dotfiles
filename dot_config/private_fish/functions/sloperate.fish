function sloperate
    argparse 'w/write' -- $argv
    or return 1

    set -l ro_token (op read "op://Personal/wifgmxloplrng3gcpgj3hpn7me/uammdt57uhh7hqhlqfht3w7rji")
    if test $status -ne 0
        echo "sloperate: failed to read RO PAT from 1Password" >&2
        return 1
    end

    set -l gh_token $ro_token
    if set -q _flag_write
        set gh_token (op read "op://Personal/nh7nrooz5ksbkwu6en4epxl2qy/c52d7vdpy6sg37fmxpfniw7ofy")
        if test $status -ne 0
            echo "sloperate: failed to read RW PAT from 1Password" >&2
            return 1
        end
    end

    # --user 1001: imani's UID in Ubuntu cloud images (ubuntu preseeds 1000);
    # container has raw.idmap "both 1000 1001" mapping it to host UID 1000
    lxc exec --user 1001 --cwd "$PWD" \
        --env HOME=/home/imani        \
        --env USER=imani              \
        --env LOGNAME=imani           \
        --env SHELL=/bin/bash         \
        --env PATH="$PATH"            \
        --env GH_TOKEN="$gh_token"    \
        opencode -- opencode $argv
end
