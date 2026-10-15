-- Automatically cd to the project root of the file you opened.
-- Root is detected by the .git directory only, so launching
-- `nvim path/to/file.py` from $HOME still scopes :pwd (and Telescope's
-- <leader>sf) to the repo the file belongs to.

return {
  {
    'ahmedkhalf/project.nvim',
    -- Run early so the cwd is corrected before other plugins care about it
    lazy = false,
    main = 'project_nvim',
    opts = {
      -- Pattern-only: the 'lsp' method would chdir to server roots
      -- (package.json, pyproject.toml, ...) even without a .git marker.
      detection_methods = { 'pattern' },
      patterns = { '.git' },
      -- Don't announce every directory change
      silent_chdir = true,
      -- Only chdir for real files, not oil.nvim/neo-tree/fugitive buffers etc.
      exclude_dirs = {},
      ignore_lsp = {},
      scope_chdir = 'global',
    },
    keys = {
      {
        '<leader>sp',
        function()
          require('telescope').extensions.projects.projects()
        end,
        desc = '[S]earch [P]rojects (recent)',
      },
    },
    init = function()
      -- Handle `nvim path/to/dir`: cd to the directory argument at startup so
      -- the initial file viewer (netrw) and Telescope are scoped correctly.
      vim.api.nvim_create_autocmd('VimEnter', {
        group = vim.api.nvim_create_augroup('startup-cd-to-dir-arg', { clear = true }),
        callback = function()
          local arg = vim.fn.argv(0)
          if arg and arg ~= '' then
            local path = vim.fn.fnamemodify(arg, ':p')
            if vim.fn.isdirectory(path) == 1 then
              vim.cmd.cd(path)
            end
          end
        end,
      })
    end,
  },
}
