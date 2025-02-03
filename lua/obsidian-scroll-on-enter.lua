-- yoinked from https://github.com/oflisback/obsidian-bridge.nvim/blob/main/lua/obsidian-bridge/event_handlers.lua
local function get_vault_name(path)
	local current_path = vim.fn.expand(path)
	while current_path ~= "/" do
		local obsidian_folder = current_path .. "/.obsidian"
		if vim.fn.isdirectory(obsidian_folder) == 1 then
			local vault_name = obsidian_folder:match("/([^/]+)/%.obsidian$")
			return vault_name:gsub("([^%w])", "%%%1")
		end
		current_path = vim.fn.fnamemodify(current_path, ":h")
	end
	return false
end
local function get_active_buffer_obsidian_markdown_filename()
	local bufnr = vim.api.nvim_get_current_buf()
	local filename_incl_path = vim.api.nvim_buf_get_name(bufnr)
	if filename_incl_path == nil or string.sub(filename_incl_path, -3) ~= ".md" then
		return nil
	end

	if vim.fn.has("win32") then
		filename_incl_path = string.gsub(filename_incl_path, "\\", "/")
	end

	local path = vim.fn.fnamemodify(filename_incl_path, ":p:h")
	local vault_name = get_vault_name(path)
	if not vault_name then
		return nil
	end

	return filename_incl_path:match(".*/" .. vault_name .. "/(.*)")
end

vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Auto scroll obsidian to bottom',
  pattern = { '*.md', },
  callback = function()
    local config = require('obsidian-bridge.config')
    local network = require('obsidian-bridge.network')
    if not config.on then
      return
    end
    local filename = get_active_buffer_obsidian_markdown_filename()
    if filename == nil then
      return
    end

    local api_key = config.get_api_key()
    local fc = config.final_config
    if api_key ~= nil then
      vim.defer_fn(function()
	network.execute_command(fc, api_key, 'POST', 'page-scroll:page-scroll-bottom')
	vim.defer_fn(function()
	  network.execute_command(fc, api_key, 'POST', 'page-scroll:page-scroll-down')
	end, 50)
      end, 250)
    end
  end,
})
