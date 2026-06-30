function lxc-launch
     set pure false
     set pass_args
     for arg in $argv
         if test "$arg" = --pure
             set pure true
         else
             set pass_args $pass_args $arg
         end
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

     echo "Waiting for $container..."
     lxc exec $container -- bash -c \
         'until systemctl is-active --quiet default.target 2>/dev/null; do sleep 1; done'

     echo "Installing fish and creating imani user..."
     lxc exec --env DEBIAN_FRONTEND=noninteractive --env NEEDRESTART_MODE=a $container -- bash -c '
         add-apt-repository -y ppa:fish-shell/release-4
         apt-get update
         apt-get install -y -q fish
         useradd -m -s /usr/bin/fish -G sudo imani
         echo "imani ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/imani
         chmod 0440 /etc/sudoers.d/imani
     '

     echo "Applying dotfiles..."
     lxc exec $container -- \
         sh -c 'sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin'

     # Run chezmoi as imani with a proper logind session
     lxc exec --env DEBIAN_FRONTEND=noninteractive --env NEEDRESTART_MODE=a $container -- su -l imani -c \
         'chezmoi init --apply https://github.com/bepri/dotfiles'

     echo "Done. Container $container is ready."
 end
