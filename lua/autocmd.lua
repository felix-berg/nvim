-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local isQuitting = false

vim.api.nvim_create_autocmd('VimLeavePre', {
  desc = 'Set `isQuitting`',
  pattern = { '*' },
  callback = function()
    isQuitting = true
  end,
})

vim.api.nvim_create_autocmd('BufWritePost', {
  desc = 'Auto-exec latex',
  pattern = { '*.tex' },
  callback = function()
    if isQuitting then
      return
    end
    vim.cmd [[ Run ]]
  end,
})
