function _tide_item_python
    if test -n "$VIRTUAL_ENV"
        if command -q python3
            python3 --version | string match -qr "(?<v>[\d.]+)"
        else
            python --version | string match -qr "(?<v>[\d.]+)"
        end
        string match -qr "^.*/(?<dir>.*)/(?<base>.*)" $VIRTUAL_ENV
        # pipenv $VIRTUAL_ENV looks like /home/ilan/.local/share/virtualenvs/pipenv_project-EwRYuc3l
        # Detect whether we are using pipenv by looking for 'virtualenvs'. If so, remove the hash at the end.
        if test "$dir" = virtualenvs
            string match -qr "(?<base>.*)-.*" $base
            _tide_print_item python $tide_python_icon' ' "$base"
        else if contains -- "$base" virtualenv venv .venv env # avoid generic names
            _tide_print_item python $tide_python_icon' ' "$dir"
        else
            _tide_print_item python $tide_python_icon' ' "$base"
        end
    end
end
