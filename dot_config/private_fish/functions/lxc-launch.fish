function lxc-launch
     set pure false
     set minimal false
     set container_type ""
     set pass_args
     set expect_type false
     for arg in $argv
         if $expect_type
             if not contains -- $arg ai work
                 echo "lxc-launch: unknown container type '$arg' (expected: ai, work)" >&2
                 return 1
             end
             set container_type $arg
             set expect_type false
         else if test "$arg" = --pure
             set pure true
         else if test "$arg" = --minimal
             set minimal true
         else if test "$arg" = --type
             set expect_type true
         else
             set pass_args $pass_args $arg
         end
     end

     if $expect_type
         echo "lxc-launch: --type requires an argument (ai, work)" >&2
         return 1
     end

     lxc launch $pass_args
     or return 1

     if $pure
         return 0
     end

     # Infer container name: non-flag arg without ':' (images always have ':')
     set container ""
     for arg in $pass_args
         if not string match -qr -- '^-|:' $arg
             set container $arg
         end
     end

     if test -z "$container"
         echo "lxc-launch: could not determine container name, skipping setup" >&2
         return 0
     end

     if test "$container_type" = ai
         echo "Configuring idmap and shared mounts..."
         # imani is UID 1001 in Ubuntu cloud images (ubuntu user takes 1000)
         lxc config set $container raw.idmap "both 1000 1001"
         lxc restart $container
         lxc config device add $container HostHome disk source=/home/imani path=/mnt/host-home readonly=true
         lxc config device add $container Personal disk source=/home/imani/dev path=/home/imani/dev
         lxc config device add $container Projects disk source=/home/imani/work path=/home/imani/work
     end

     echo "Waiting for $container..."
     lxc exec $container -- bash -c \
         'until systemctl is-active --quiet default.target 2>/dev/null; do sleep 1; done'

     echo "Installing fish and creating imani user..."
     lxc exec --env DEBIAN_FRONTEND=noninteractive --env NEEDRESTART_MODE=a $container -- bash -c '
         add-apt-repository -y ppa:fish-shell/release-4
         apt-get update
         apt-get install -y -q fish
         useradd -m -s /usr/bin/fish -G sudo imani
         # Home dir may pre-exist (root-owned) if disk devices created mount parents
         chown imani:imani /home/imani
         echo "imani ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/imani
         chmod 0440 /etc/sudoers.d/imani
     '

     echo "Applying dotfiles..."
     lxc exec $container -- \
         sh -c 'sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin'

    if $minimal
        lxc exec $container -- su -l imani -c 'mkdir -p ~/.config && echo "THIS FILE IS BLOCKING CARGO INSTALLS FROM CHEZMOI" > ~/.config/.no-cargo'
    end

    if test "$container_type" = ai
        echo "Installing dangertoaster signing key..."
        set -l tmpdir (mktemp -d)
        op read "op://Personal/eo7v6boyrcegofvn34dk2sgomu/private_key" > $tmpdir/dangertoaster_sign
        or begin
            echo "lxc-launch: failed to read signing key from 1Password" >&2
            rm -rf $tmpdir
            return 1
        end
        op read "op://Personal/eo7v6boyrcegofvn34dk2sgomu/public_key" > $tmpdir/dangertoaster_sign.pub
        lxc exec $container -- su -l imani -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh'
        lxc file push --uid 1001 --gid 1001 --mode 600 $tmpdir/dangertoaster_sign $container/home/imani/.ssh/dangertoaster_sign
        lxc file push --uid 1001 --gid 1001 --mode 644 $tmpdir/dangertoaster_sign.pub $container/home/imani/.ssh/dangertoaster_sign.pub
        rm -rf $tmpdir
    end

     # Run chezmoi as imani with a proper logind session
     # CHEZMOI_CONTAINER_TYPE drives type-specific template rendering (e.g. gitconfig identity)
     lxc exec --env DEBIAN_FRONTEND=noninteractive --env NEEDRESTART_MODE=a $container -- su -l imani -c \
         "CHEZMOI_CONTAINER_TYPE=$container_type chezmoi init --apply https://github.com/bepri/dotfiles"

     echo "Done. Container $container is ready."
 end
