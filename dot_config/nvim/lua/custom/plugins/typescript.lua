-- TypeScript/JavaScript development: vitest adapter + vscode-js-debug.

-- Mutable so the <leader>tdj toggle applies to subsequent debug sessions.
local dap_skip_files = { '<node_internals>/**' }

--- JS analogue of the python justMyCode toggle: swap skipFiles between
--- "node internals only" (step into node_modules) and "also node_modules".
local function toggle_skip_files()
  local skipping = #dap_skip_files > 1
  if skipping then
    dap_skip_files = { '<node_internals>/**' }
  else
    dap_skip_files = { '<node_internals>/**', '**/node_modules/**' }
  end
  local dap = require 'dap'
  for _, lang in ipairs { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' } do
    for _, cfg in ipairs(dap.configurations[lang] or {}) do
      cfg.skipFiles = dap_skip_files
    end
  end
  vim.notify('skip node_modules: ' .. tostring(not skipping), vim.log.levels.INFO)
end

return {
  {
    'nvim-neotest/neotest',
    dependencies = { 'marilari88/neotest-vitest' },
    -- Function form: adapter requires must run at load time, when plugin
    -- dependencies are on the runtimepath. testing.lua owns setup and keys.
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require 'neotest-vitest' {})
    end,
    init = function()
      -- Buffer-local so it overrides the python <leader>tdj binding only in
      -- JS/TS buffers.
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
        callback = function(event)
          vim.keymap.set('n', '<leader>tdj', toggle_skip_files, {
            buffer = event.buf,
            desc = '[T]est [D]ebug Toggle skip node_modules',
          })
        end,
      })
    end,
  },

  {
    'mxsdev/nvim-dap-vscode-js',
    dependencies = {
      'mfussenegger/nvim-dap',
      {
        'microsoft/vscode-js-debug',
        -- The adapter ships as a vscode extension; build the debug server.
        build = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out',
      },
    },
    ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
    config = function()
      require('dap-vscode-js').setup {
        adapters = { 'pwa-node', 'pwa-chrome' },
      }

      local dap = require 'dap'
      for _, lang in ipairs { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' } do
        dap.configurations[lang] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
            skipFiles = dap_skip_files,
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach to process',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
            skipFiles = dap_skip_files,
          },
        }
      end
    end,
  },
}
