-- Plugins that affect general editing behavior:
-- indentation detection, git signs/commands, file explorer, mini modules.

return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  { 'tpope/vim-fugitive' },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },

  { -- Collection of QoL plugins; used here for persistent toggleable terminals
    -- and as the fuzzy finder (picker replaces telescope).
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- Fuzzy finder. `ui_select = true` is the default, which routes
      -- vim.ui.select() through the picker (replacing telescope-ui-select).
      picker = {},
      terminal = {
        -- Don't force insert mode on every BufEnter: after <Esc><Esc> you stay
        -- in normal mode until you press i, like any other buffer.
        auto_insert = false,
        win = {
          keys = {
            -- Replace snacks' timer-based double-Esc (which leaks the first
            -- Esc into the terminal, folke/snacks.nvim#124) with a native
            -- expr mapping. Also allow hiding the terminal from normal mode.
            term_normal = {
              '<esc><esc>',
              function()
                return '<C-\\><C-n>'
              end,
              mode = 't',
              expr = true,
              desc = 'Double escape to normal mode',
            },
            q = 'hide',
            ['<esc>'] = 'hide',
          },
        },
      },
    },
    init = function()
      vim.keymap.set('n', '<leader>ot', function()
        Snacks.terminal.toggle()
      end, { desc = '[O]pen [T]erminal' })
      vim.keymap.set('n', '<leader>slop', function()
        Snacks.terminal.toggle 'fish -ic sloperate'
      end, { desc = 'Toggle sloperate (read-only)' })
      vim.keymap.set('n', '<leader>sloP', function()
        Snacks.terminal.toggle 'fish -ic "sloperate --write"'
      end, { desc = 'Toggle sloperate (read-write)' })

      -- [[ Search keymaps (snacks.picker; formerly telescope) ]]
      local function picker(name)
        return function()
          return Snacks.picker[name]()
        end
      end
      vim.keymap.set('n', '<leader>sh', picker 'help', { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', picker 'keymaps', { desc = '[S]earch [K]eymaps' })
      -- Search files in the current workspace (cwd), showing dotfiles but not .git/
      -- (snacks' files finder excludes .git by default).
      vim.keymap.set('n', '<leader>sf', function()
        Snacks.picker.files { title = 'Files in ' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':~'), hidden = true }
      end, { desc = '[S]earch [F]iles (cwd, dotfiles included)' })
      -- Old behavior: search ALL files, including hidden and gitignored ones
      vim.keymap.set('n', '<leader>sF', function()
        Snacks.picker.files { title = 'ALL Files (hidden + ignored)', hidden = true, ignored = true }
      end, { desc = '[S]earch [F]iles EVERYWHERE (incl. hidden/gitignored)' })
      vim.keymap.set('n', '<leader>ss', picker 'pickers', { desc = '[S]earch [S]elect Picker' })
      vim.keymap.set('n', '<leader>sw', picker 'grep_word', { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', picker 'grep', { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', picker 'diagnostics', { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', picker 'resume', { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', picker 'recent', { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', picker 'buffers', { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>/', picker 'lines', { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>s/', picker 'grep_buffers', { desc = '[S]earch [/] in Open Files' })
      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
      -- Command palette: fuzzy-find and run any :command (builtin and plugin).
      vim.keymap.set('n', '<C-S-p>', picker 'commands', { desc = 'Command palette' })
      vim.keymap.set('n', '<leader>:', picker 'commands', { desc = 'Command palette' })
    end,
  },
}
