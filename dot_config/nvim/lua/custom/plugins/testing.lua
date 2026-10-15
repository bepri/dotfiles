-- Shared test running (neotest) and debugging (nvim-dap + dap-ui).
-- Language files (python.lua, typescript.lua) contribute adapters via
-- opts merging and define their language-specific debug toggles.

return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'mfussenegger/nvim-dap',
    },
    -- opts starts empty; language specs merge their adapters in.
    opts = {},
    init = function()
      ---@param ref string Reference name for icon
      ---@param icon string Icon to display
      ---@param is_nerd? boolean Whether or not this is a nerd font, default false
      local simple_icon = function(ref, icon, is_nerd)
        if ((is_nerd or false) and vim.g.have_nerd_font) or not is_nerd then
          vim.fn.sign_define(ref, { text = icon, texthl = '', linehl = '', numhl = '' })
        end
      end

      simple_icon('DapBreakpoint', '', true)
    end,
    keys = {
      -- Toggle the test summary tree (files -> tests, with run/debug actions)
      {
        '<leader>tt',
        function()
          require('neotest').summary.toggle()
        end,
        desc = '[T]est [T]ree (summary)',
      },
      -- Run nearest tests
      {
        '<leader>tn',
        function()
          require('neotest').run.run()
        end,
        desc = '[T]est [N]earest',
      },
      -- Run all tests
      {
        '<leader>tf',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = '[T]est [F]ile',
      },
      -- Stop tests
      {
        '<leader>ts',
        function()
          require('neotest').run.stop(vim.fn.expand '%')
        end,
        desc = '[T]est [S]top',
      },
      -- Attach to test
      {
        '<leader>ta',
        function()
          require('neotest').run.attach()
        end,
        desc = '[T]est [A]ttach',
      },
      -- Retrospect test
      {
        '<leader>tw',
        function()
          require('neotest').output.open { auto_close = true, quiet = true, enter = true }
        end,
        desc = '[T]est [W]hy Failed',
      },
      -- Debug nearest test
      {
        '<leader>tdn',
        function()
          require('neotest').run.run { strategy = 'dap' }
        end,
        desc = '[T]est [D]ebug [N]earest',
      },
      -- Toggle breakpoint
      {
        '<leader>tdb',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = '[T]est [D]ebug Toggle [B]reakpoint',
      },
      -- Step over
      {
        '<leader>tds',
        function()
          require('dap').step_over()
        end,
        desc = '[T]est [D]ebug [S]tep over',
      },
      -- Step into
      {
        '<leader>tdi',
        function()
          require('dap').step_into()
        end,
        desc = '[T]est [D]ebug [I]nto',
      },
      -- Debug continue
      {
        '<leader>tdc',
        function()
          require('dap').continue()
        end,
        desc = '[T]est [D]ebug [C]ontinue',
      },
    },
  },

  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    keys = {
      -- Evaluate expression under cursor (or visual selection) in a float
      {
        '<leader>tde',
        function()
          require('dapui').eval()
        end,
        mode = { 'n', 'v' },
        desc = '[T]est [D]ebug [E]val expression',
      },
      -- Toggle the debug UI panels manually
      {
        '<leader>tdu',
        function()
          require('dapui').toggle()
        end,
        desc = '[T]est [D]ebug [U]I toggle',
      },
    },
    config = function()
      local dap, dapui = require 'dap', require 'dapui'
      dapui.setup()

      -- Auto-open panels when a debug session starts, close when it ends
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },
}
