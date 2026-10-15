bind \b "backward-kill-word"
# Under kitty's keyboard protocol, ctrl-backspace is distinct from \b.
# Keep it a word kill, not fish's token kill (which eats quoted strings whole).
bind ctrl-backspace "backward-kill-word"

# In-place prompt redraw, used by neovim config
bind \x1f "commandline -f repaint"