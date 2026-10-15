-- Python development: venv selection, testing, debugging, pytest fixture jumping.

-- Shared DAP args for neotest-python. Kept in a local so the <leader>tdj
-- toggle can mutate `justMyCode` and have it apply to subsequent sessions.
local neotest_dap_args = { justMyCode = false }

return {
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim', 'mfussenegger/nvim-dap-python' },
    branch = 'main',
    -- Defaults cover the common case: built-in searches find `.venv` etc.,
    -- and your last-selected venv is cached + auto-activated per workspace.
    opts = {},
  },

  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/neotest-python',
      {
        'mfussenegger/nvim-dap-python',
        init = function()
          -- Default: step INTO library code (justMyCode = false).
          -- Toggle at runtime with <leader>tdj.
          neotest_dap_args.justMyCode = false
          require('dap-python').setup 'uv'
          -- dap-python defaults its launch configs to justMyCode = true;
          -- align them with our default.
          for _, cfg in ipairs(require('dap').configurations.python or {}) do
            cfg.justMyCode = false
          end
        end,
      },
    },
    -- Function form: adapter requires must run at load time, when plugin
    -- dependencies are on the runtimepath. testing.lua owns setup and keys.
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(
        opts.adapters,
        require('neotest-python') {
          -- justMyCode is managed by the <leader>tdj toggle (default false:
          -- step into library code).
          dap = neotest_dap_args,
        }
      )
    end,
    keys = {
      -- Toggle justMyCode: when on, stepping skips library/site-packages code
      {
        '<leader>tdj',
        function()
          neotest_dap_args.justMyCode = not neotest_dap_args.justMyCode
          -- Also update dap-python's own configurations (debug file, etc.)
          local dap = require 'dap'
          for _, cfg in ipairs(dap.configurations.python or {}) do
            cfg.justMyCode = neotest_dap_args.justMyCode
          end
          vim.notify('justMyCode: ' .. tostring(neotest_dap_args.justMyCode), vim.log.levels.INFO)
        end,
        desc = '[T]est [D]ebug Toggle [J]ustMyCode',
      },
    },
  },

  {
    'acksld/nvim-pytrize.lua',
    keys = {
      -- Jump to fixture
      {
        '<leader>lf',
        function()
          require('pytrize.api').jump_fixture()
        end,
        desc = '[L]SP-ish: Goto [F]ixture (pytest)',
      },
    },
  },
}
