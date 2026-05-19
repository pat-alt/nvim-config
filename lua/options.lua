-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Added by me:
vim.opt.spell = true

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Enable 24-bit (truecolor) highlights so hex colors below work.
vim.opt.termguicolors = true

-- Default colorscheme. Switch interactively via `<leader>vc` (`:Telescope colorscheme`).
vim.cmd.colorscheme 'lunaperche'

-- Show which line your cursor is on
vim.opt.cursorline = true
vim.opt.cursorcolumn = true

-- Make the CursorColumn bar more prominent, and keep it that way when the
-- colorscheme or background changes (`<leader>vc` / `<leader>td`).
local cursor_col_group = vim.api.nvim_create_augroup('UserCursorColumn', { clear = true })
local function tweak_cursor_column()
  -- Inherit the active theme's own ColorColumn background so the bar stays
  -- theme-appropriate on any colorscheme.
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = 'ColorColumn', link = false })
  if ok and hl and hl.bg then
    pcall(vim.api.nvim_set_hl, 0, 'CursorColumn', { bg = hl.bg })
  end
end
vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
  group = cursor_col_group,
  callback = tweak_cursor_column,
})
vim.api.nvim_create_autocmd('OptionSet', {
  group = cursor_col_group,
  pattern = 'background',
  callback = tweak_cursor_column,
})

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- Clipboard yanking
vim.opt.clipboard = "unnamedplus"

-- vim: ts=2 sts=2 sw=2 et
