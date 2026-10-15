-- Automatic session resume, nothing more.
--
-- Workflow: quit nvim mid-work in a project -> `nvim path/to/project` later
-- (or `nvim .` inside it) -> buffers/tabs/windows come back as you left them.
-- No keybindings, no manual save/restore commands needed.
--
-- Caveat: breakpoints are nvim-dap runtime state and are NOT restored.

return {
  {
    'rmagatti/auto-session',
    lazy = false,
    opts = {
      auto_save = true, -- save on exit, silently
      auto_restore = true, -- restore when launching into a known directory
      -- Restore even when given a single directory argument (`nvim <repo>`),
      -- but NOT when given an actual file (`nvim foo.py` opens just that file)
      args_allow_single_directory = true,
      args_allow_files_auto_save = false,
      -- Never auto-save in these directories
      suppressed_dirs = { '~/', '~/Downloads', '/tmp' },
      -- Don't save a "session" that only has a file viewer open
      bypass_save_filetypes = { 'netrw', 'neo-tree' },
      -- We manage cwd ourselves (project.nvim); auto-session's own
      -- DirChanged session-swapping would fight with that
      cwd_change_handling = false,
    },
  },
}
