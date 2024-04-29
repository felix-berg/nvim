-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Shorthand to remove words
vim.keymap.set('i', '<C-BS>', '<C-W>')
vim.keymap.set('i', '<C-H>', '<C-W>')

-- fat fingers have hard time ok
vim.keymap.set('n', '´', '$')

-- call :Run command
vim.keymap.set('n', '<leader>ewr', '<cmd>WriteRun<CR>', { desc = 'Write and run the current file' })
vim.keymap.set('n', '<leader>er', '<cmd>Run<CR>', { desc = 'Run the current file' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Create mapping for tabs
vim.keymap.set('n', '<leader>tn', vim.cmd.tabnew, { desc = 'Open a [n]ew [t]ab' })
vim.keymap.set('n', '<leader>tq', vim.cmd.tabclose, { desc = 'Close current tab' })
vim.keymap.set('n', '<leader>1', '1gt', { desc = 'Move to tab 1' })
vim.keymap.set('n', '<leader>2', '2gt', { desc = 'Move to tab 2' })
vim.keymap.set('n', '<leader>3', '3gt', { desc = 'Move to tab 3' })
vim.keymap.set('n', '<leader>4', '4gt', { desc = 'Move to tab 4' })
vim.keymap.set('n', '<leader>5', '5gt', { desc = 'Move to tab 5' })
vim.keymap.set('n', '<leader>6', '6gt', { desc = 'Move to tab 6' })
vim.keymap.set('n', '<leader>7', '7gt', { desc = 'Move to tab 7' })
vim.keymap.set('n', '<leader>8', '8gt', { desc = 'Move to tab 8' })
vim.keymap.set('n', '<leader>9', '9gt', { desc = 'Move to tab 9' })
vim.keymap.set('n', '<leader>0', '<cmd>tablast<CR>', { desc = 'Move to tab 9' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- move to previous view
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set('n', '<C-z>', '<cmd>echo "Don\'t press Ctrl+z you dumbo"<CR>')

vim.keymap.set('i', '<left>', '<cmd>echo "Use Alt+h to move!!"<CR>')
vim.keymap.set('i', '<right>', '<cmd>echo "Use Alt+l to move!!"<CR>')
vim.keymap.set('i', '<up>', '<cmd>echo "Use Alt+k to move!!"<CR>')
vim.keymap.set('i', '<down>', '<cmd>echo "Use Alt+j to move!!"<CR>')

vim.keymap.set('n', '<leader>nr', '<cmd>set invrnu<CR>', { desc = 'Toggle relative numbering' })
