local function splitstr(str, delim)
  local t = {}
  for substr in string.gmatch(str, '[^' .. delim .. ']+') do
    table.insert(t, substr)
  end
  return t
end

local function removeExtension(file)
  local t = splitstr(file, '%.')
  return table.concat(t, '.', 1, #t - 1)
end

vim.api.nvim_create_user_command('OpenPDF', function()
  local file = vim.api.nvim_buf_get_name(0)
  local name = removeExtension(vim.fs.basename(file))
  local outdir = string.format('%s/out', vim.fs.dirname(file))
  local pdf = string.format('%s/%s.pdf', outdir, name)

  vim.fn.jobstart({ 'xdg-open', pdf }, {
    detach = true,
  })
end, {})
