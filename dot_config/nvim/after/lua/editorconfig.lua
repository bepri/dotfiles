vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = vim.api.nvim_create_augroup('FormatOptions', { clear = true }),
  pattern = { '*.py' },
  callback = function()
    vim.opt_local.fo:remove 't'
  end,
})
