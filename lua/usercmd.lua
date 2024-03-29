local function notifyOutputStream(_, data)
  if data then
    vim.notify(data[1], nil, {})
  end
end

local function cmdToStr(cmd)
  local str = ''
  for _, s in ipairs(cmd) do
    str = string.format('%s %s', str, s)
  end
  return str
end

local function sequentialCommands(list)
  for _, cmd in ipairs(list) do
    local rc = vim.fn.jobstart(cmd, {
      on_stdout = notifyOutputStream,
      on_stderr = notifyOutputStream,
      buffered_stdout = true,
    })
    if rc ~= 0 then
      vim.notify(string.format('failed while executing command: %s', cmdToStr(cmd)), nil, {})
      return
    end
  end
end

local runmap = {
  'main.cpp',
}

vim.api.nvim_create_user_command('Run', function()
  local filename = vim.api.nvim_buf_get_name(0)
  sequentialCommands {
    { 'cat', string.format('%s', filename) },
  }
end, {})
