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
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
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
      end, { desc = 'Toggle sloperate' })
    end,
  },
}
