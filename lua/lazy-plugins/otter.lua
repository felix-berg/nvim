vim.api.nvim_create_user_command('Otter', function()
  require('otter').activate()
end, {})

return {
  'jmbuhr/otter.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {}
}
