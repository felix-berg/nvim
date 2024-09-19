-- TODO: bug - doesn't preserve empty lines
local function outputStream(log)
  return function(_, data)
    for i = 1, #data, 1 do
      log(data[i])
    end
  end
end

local function cmdToStr(cmd)
  local str = ''
  for _, s in ipairs(cmd) do
    str = string.format('%s %s', str, s)
  end
  return str
end


local function startCommandJob(log, cmd, on_exit)
  return vim.fn.jobstart(cmd, {
    on_stdout = outputStream(log),
    on_stderr = outputStream(log),
    on_exit = on_exit,
  })
end

local MAX_COMMAND_SECS = 1000000000000 -- (TODO: cmdline argument)
local function sequentialCommandsImpl(log, iter, clb, starttime)
  local cmd = iter()

  if cmd == nil then
    clb(true)
    return
  elseif os.time() - starttime > MAX_COMMAND_SECS then
    log(string.format("exceeded maximum time of %d ms while executing command: '%s'", MAX_COMMAND_SECS, cmdToStr(cmd)))
    clb(false)
    return
  end

  startCommandJob(log, cmd, function(_, ec)
    if ec ~= 0 then
      clb(false)
      return
    end

    sequentialCommandsImpl(log, iter, function(success)
      clb(success)
    end, starttime)
  end)
end

local function sequentialCommands(list, log, callback)
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

  sequentialCommandsImpl(log, cmditer, callback, os.time())
end

local function matchesPattern(str, pattern)
  return string.match(str, pattern) == str
end

local function runLatex(f)
  local file = vim.fs.normalize(f)
  local dir = vim.fs.dirname(f)

  sequentialCommands({
    { 'mkdir', '-p', 'out' },
    { 'pdflatex', '-interaction=nonstopmode', '-output-directory', string.format('%s/out', dir), string.format('"%s"', file) },
  }, function(str)
    print(str)
  end, function(_)
    print '----- finished -----'
  end)
end

local function run(file)
  local runmap = {
    {
      name = 'Latex document',
      patterns = { '.*%.tex' },
      run = runLatex,
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

