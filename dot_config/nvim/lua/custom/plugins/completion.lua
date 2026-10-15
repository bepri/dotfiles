-- Autocompletion via blink.cmp (modern, batteries-included replacement for nvim-cmp)
-- Pinned to v1.x for stability; v2 has breaking changes in flight.

return {
  {
    'saghen/blink.cmp',
    version = '1.*',
    event = 'InsertEnter',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- Keymap preset close to the old nvim-cmp setup:
      --   <C-n>/<C-p> navigate, <C-y> accept, <C-b>/<C-f> scroll docs, <C-Space> open menu
      keymap = {
        preset = 'default',
        ['<C-y>'] = { 'select_and_accept' },
      },

      appearance = {
        -- Use Nerd Font icons if available
        nerd_font_variant = vim.g.have_nerd_font and 'mono' or 'normal',
      },

      completion = {
        -- Controlled by the <leader>tc toggle: when false, the menu only
        -- appears on manual trigger (<C-Space>).
        menu = {
          auto_show = function()
            return vim.g.blink_auto_show ~= false
          end,
        },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },

      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
      },

      -- Native vim.snippet expansion: no external snippet engine needed.
      -- LSP snippets (function placeholders etc.) work out of the box.
      snippets = { preset = 'default' },

      -- Rust fuzzy matcher with prebuilt binary download; falls back to Lua
      fuzzy = { implementation = 'prefer_rust_with_warning' },

      -- Signature help replaces the old cmp-nvim-lsp-signature-help source
      signature = { enabled = true },
    },
    opts_extend = { 'sources.default' },
    init = function()
      -- Default: completion menu shows automatically while typing.
      vim.g.blink_auto_show = true
    end,
    keys = {
      {
        -- Toggle automatic completion menu on/off. Manual trigger via
        -- <C-Space> works regardless of this setting.
        '<leader>tc',
        function()
          vim.g.blink_auto_show = not vim.g.blink_auto_show
          local state = vim.g.blink_auto_show and 'on' or 'off (use <C-Space>)'
          vim.notify('Auto-completion ' .. state, vim.log.levels.INFO)
        end,
        desc = '[T]oggle auto-[C]ompletion',
      },
    },
  },
}
