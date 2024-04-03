-- TODO: bug - doesn't preserve empty lines
local function splitstr(str, delim)
  local t = {}

  for substr in string.gmatch(str, '[^' .. delim .. ']+') do
    table.insert(t, substr)
  end

  return t
end

local function windowAppend(window, string)
  local buffer = vim.api.nvim_win_get_buf(window)
  local nlines = vim.api.nvim_buf_line_count(buffer)

  local lastline = vim.api.nvim_buf_get_lines(buffer, -1, -1, true)[1]
  lastline = lastline == nil and '' or lastline
  lastline = string.format('%s%s', lastline, string)

  local lines = splitstr(lastline, '\n')
  vim.api.nvim_buf_set_lines(buffer, nlines - 1, nlines - 1, true, lines)
  vim.api.nvim_win_set_cursor(window, { nlines, 0 })
end

local function clearWindow(window)
  local buffer = vim.api.nvim_win_get_buf(window)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
end

local function outputstream(window)
  return function(_, data)
    local str = table.concat(data, '\n', 1, #data - 1)
    windowAppend(window, str)
  end
end

local function cmdToStr(cmd)
  local str = ''
  for _, s in ipairs(cmd) do
    str = string.format('%s %s', str, s)
  end
  return str
end

local outputWindows = {}

function CloseOutputWindow(window)
  if window == nil then
    window = vim.api.nvim_get_current_win()
  end

  local bufnr = vim.api.nvim_win_get_buf(window)
  vim.api.nvim_win_close(window, true)
  vim.api.nvim_buf_delete(bufnr, { force = true })
  outputWindows[window] = nil
end

local function initOutputWindow(identifier, recall)
  local origwin = vim.api.nvim_get_current_win()

  for win, obj in pairs(outputWindows) do
    if obj.identifier == identifier then
      clearWindow(win)
      return win
    end
  end

  vim.cmd [[ vne ]]
  local window = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(window)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>lua CloseOutputWindow()<CR>', { silent = false })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', '<cmd>lua CloseOutputWindow()<CR>', { silent = false })

  outputWindows[window] = {
    identifier = identifier,
    recall = recall,
  }

  vim.api.nvim_set_current_win(origwin)

  return window
end

local function outputWinIsOpen(window)
  return outputWindows[window] ~= nil
end

local function startCommandJob(window, cmd, on_exit)
  return vim.fn.jobstart(cmd, {
    on_stdout = outputstream(window),
    on_stderr = outputstream(window),
    width = vim.api.nvim_win_get_width(window), -- width of internal pty
    on_exit = on_exit,
  })
end

local MAX_COMMAND_SECS = 1000000000000 -- (TODO: cmdline argument)
local function sequentialCommandsImpl(window, iter, clb, starttime)
  local cmd = iter()

  if cmd == nil then
    clb(true)
    return
  elseif not outputWinIsOpen(window) then
    clb(false)
    return
  elseif os.time() - starttime > MAX_COMMAND_SECS then
    windowAppend(window, string.format("exceeded maximum time of %d ms while executing command: '%s'", MAX_COMMAND_SECS, cmdToStr(cmd)))
    clb(false)
    return
  end

  startCommandJob(window, cmd, function(_, ec)
    if ec ~= 0 then
      clb(false)
      return
    end

    sequentialCommandsImpl(window, iter, function(success)
      clb(success)
    end, starttime)
  end)
end

local function sequentialCommands(window, list, callback)
  local i = 1

  local cmditer = function()
    if i > #list then
      return nil
    else
      local cmd = list[i]
      i = i + 1
      return cmd
    end
  end

  sequentialCommandsImpl(window, cmditer, callback, os.time())
end

local function matchesPattern(str, pattern)
  return string.match(str, pattern) == str
end

local function findExecutable(dir)
  for file in vim.fs.dir(dir) do
    local abs = string.format('%s/%s', dir, file)
    if vim.fn.executable(abs) == 1 then
      return abs
    end
  end
  return nil
end

local function dirIncludes(dir, filename)
  for file in vim.fs.dir(dir) do
    if file == filename then
      return true
    end
  end
  return false
end

local function outerCMakeDir(origin)
  assert(matchesPattern(origin, '/.*')) -- has to begin with '/'
  local dir = origin
  local result = nil
  while dir ~= '/' do
    if dirIncludes(dir, 'CMakeLists.txt') then
      result = dir
    end

    -- go to parent directory
    dir = vim.fs.dirname(dir)
  end

  return result
end

local function runCpp(file)
  local dir = outerCMakeDir(vim.fs.dirname(file))
  if dir == nil then
    print '----- not in a directory with CMakeLists.txt. stopping... -----'
    return
  end

  local window = initOutputWindow(dir, function()
    runCpp(file)
  end)
  local build = string.format('%s/build', dir)

  windowAppend(window, string.format('----- buildling C++ application in %s -----', dir))
  sequentialCommands(window, {
    {
      'cmake',
      '-S',
      dir,
      '-B',
      build,
      '-DCMAKE_EXPORT_COMPILE_COMMANDS=1',
      '-DCMAKE_C_COMPILER=clang',
      '-DCMAKE_CXX_COMPILER=clang++',
      '-DCMAKE_CXX_FLAGS="-stdlib=libc++"',
      '-G Ninja',
    },
    {
      'ninja',
      '-C',
      build,
    },
  }, function(success)
    if not success then
      windowAppend(window, '----- build failed, stopping... -----')
      return
    end

    local exec = findExecutable(build)
    if exec == nil then
      windowAppend(window, string.format('----- no executable found in %s -----', build))
      return
    end

    windowAppend(window, string.format("\n----- running '%s' -----", exec))
    sequentialCommands(window, { { exec } }, function(_)
      windowAppend(window, string.format '\n----- finished -----')
    end)
  end)
end

local function run(file)
  local runmap = {
    {
      name = 'C++ application',
      patterns = { '.*%.cpp', '.*/CMakeLists.txt', '.*%.hpp' },
      run = runCpp,
    },
  }

  local found = false
  for _, elem in ipairs(runmap) do
    for _, pattern in ipairs(elem.patterns) do
      if matchesPattern(file, pattern) then
        elem.run(file)
        found = true
        break
      end
    end
  end
  if not found then
    print(string.format("No run pattern matching file '%s'", vim.fs.basename(file)))
  end
end

vim.api.nvim_create_user_command('Run', function()
  run(vim.api.nvim_buf_get_name(0))
end, {})

vim.api.nvim_create_user_command('WriteRun', function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    print "Can't run empty file!"
    return
  end

  vim.cmd.write { file }
  run(file)
end, {})
