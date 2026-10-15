-- [[ Leader keys ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

vim.opt.textwidth = 0
local orig_mll = require('editorconfig').properties.max_line_length
require('editorconfig').properties.max_line_length = function(bufnr, val, opts)
  if opts.max_line_length and vim.bo.filetype ~= 'python' then
    opts.max_line_length = 0
  else
    orig_mll(bufnr, val, opts)
  end
end

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 25

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Delete the word before the cursor with Ctrl-Backspace, matching shell/editor
-- muscle memory. Requires a terminal that disambiguates <C-BS> from <BS>
-- (kitty with keyboard_protocol enabled).
vim.keymap.set('i', '<C-BS>', '<C-w>', { desc = 'Delete word backward' })

-- Ctrl-arrows jump by word in normal/insert mode; Ctrl-Shift-arrows extend a
-- visual selection by word. Same kitty keyboard protocol requirement as above.
vim.keymap.set('n', '<C-Right>', 'w', { desc = 'Jump to next word start' })
vim.keymap.set('n', '<C-Left>', 'b', { desc = 'Jump to previous word start' })
vim.keymap.set('i', '<C-Right>', '<C-o>w', { desc = 'Jump to next word start' })
vim.keymap.set('i', '<C-Left>', '<C-o>b', { desc = 'Jump to previous word start' })
vim.keymap.set('n', '<C-S-Right>', 'vw', { desc = 'Select to next word start' })
vim.keymap.set('n', '<C-S-Left>', 'vb', { desc = 'Select to previous word start' })
vim.keymap.set('i', '<C-S-Right>', '<C-o>vw', { desc = 'Select to next word start' })
vim.keymap.set('i', '<C-S-Left>', '<C-o>vb', { desc = 'Select to previous word start' })
vim.keymap.set('v', '<C-S-Right>', 'w', { desc = 'Extend selection to next word start' })
vim.keymap.set('v', '<C-S-Left>', 'b', { desc = 'Extend selection to previous word start' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- Plugin specs live in `lua/custom/plugins/*.lua` — each file returns a
-- list of plugin specs that lazy.nvim imports automatically.
require('lazy').setup({
  { import = 'custom.plugins' },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- [[ Personal keymaps and autocommands ]]

---@param mode string Neovim mapping mode (see :h nvim_set_keymap)
---@param bind string Neovim keybinding string
---@param cmd string Actual command to run. Wrapped with 'require' if wrap_req provided
---@param opts vim.api.keyset.keymap Option mapping
---@param wrap_req? string Require call to wrap with
local map = function(mode, bind, cmd, opts, wrap_req)
  if wrap_req then
    cmd = "<cmd>lua require('" .. wrap_req .. "')." .. cmd .. '<cr>'
  end
  vim.api.nvim_set_keymap(mode, bind, cmd, opts)
end

---@param desc string description of action
local build_opts = function(desc)
  local opts = { noremap = true, silent = true, desc = desc }
  return opts
end

-- barbar keybinds
map('n', '<A-,>', '<cmd>BufferPrevious<CR>', build_opts 'Previous tab')
map('n', '<A-.>', '<cmd>BufferNext<CR>', build_opts 'Next tab')
map('n', '<A-w>', '<cmd>BufferClose<CR>', build_opts 'Close tab')
map('n', '<A-p>', '<cmd>BufferPick<CR>', build_opts 'Pick buffer')

-- venv-selector keybinds
map('n', '<leader>vs', '<cmd>VenvSelect<CR>', build_opts '[V]env [S]elect')

-- autocmd groups
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  callback = function()
    vim.api.nvim_command 'setlocal nonumber norelativenumber'
  end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = vim.api.nvim_create_augroup('FormatOptions', { clear = true }),
  pattern = { '*.py' },
  callback = function()
    vim.opt_local.fo:remove 't'
  end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
