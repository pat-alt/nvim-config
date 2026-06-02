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

-- Make the current window stand out without tying the config to one colorscheme.
-- The focus dimmer preserves existing window-local highlights, such as the
-- terminal colors from `custom.config.theme-terminal`.
local focus_group = vim.api.nvim_create_augroup('UserWindowFocus', { clear = true })

local function hl(name)
  if vim.api.nvim_get_hl then
    local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok then
      return value or {}
    end
  end

  local ok, value = pcall(vim.api.nvim_get_hl_by_name, name, true)
  return ok and value or {}
end

local function color_to_hex(color)
  return color and string.format('#%06x', color) or nil
end

local function hex_to_rgb(hex)
  if not hex then
    return nil
  end

  hex = hex:gsub('#', '')
  if #hex ~= 6 then
    return nil
  end

  return {
    r = tonumber(hex:sub(1, 2), 16),
    g = tonumber(hex:sub(3, 4), 16),
    b = tonumber(hex:sub(5, 6), 16),
  }
end

local function blend(fg, bg, amount)
  fg = hex_to_rgb(fg)
  bg = hex_to_rgb(bg)
  if not fg or not bg then
    return nil
  end

  local function channel(source, target)
    return math.floor(source * amount + target * (1 - amount) + 0.5)
  end

  return string.format('#%02x%02x%02x', channel(fg.r, bg.r), channel(fg.g, bg.g), channel(fg.b, bg.b))
end

local generated_focus_groups = {
  InactiveWindow = true,
  InactiveCursorLine = true,
  InactiveCursorColumn = true,
  InactiveCursorLineNr = true,
  InactiveEndOfBuffer = true,
}

local function parse_winhighlight(value)
  local parsed = {}
  for item in string.gmatch(value or '', '[^,]+') do
    local from, to = item:match('^([^:]+):([^:]+)$')
    if from and to then
      parsed[from] = to
    end
  end
  return parsed
end

local function format_winhighlight(parsed)
  local values = {}
  for from, to in pairs(parsed) do
    table.insert(values, from .. ':' .. to)
  end
  table.sort(values)
  return table.concat(values, ',')
end

local function get_winhl(win)
  local ok, value = pcall(function()
    return vim.wo[win].winhighlight
  end)
  return ok and value or ''
end

local function set_winhl(win, value)
  pcall(function()
    vim.wo[win].winhighlight = value
  end)
end

local function strip_focus_winhighlight(value)
  local parsed = parse_winhighlight(value)
  for from, to in pairs(parsed) do
    if generated_focus_groups[to] then
      parsed[from] = nil
    end
  end
  return format_winhighlight(parsed)
end

local function set_focus_highlights()
  local normal = hl 'Normal'
  local cursor_line = hl 'CursorLine'
  local color_column = hl 'ColorColumn'
  local visual = hl 'Visual'

  local normal_bg = color_to_hex(normal.bg)
  local normal_fg = color_to_hex(normal.fg)
  local cursor_bg = color_to_hex(cursor_line.bg) or color_to_hex(color_column.bg) or normal_bg
  local accent_bg = color_to_hex(visual.bg) or cursor_bg
  local inactive_fg = blend(normal_fg, normal_bg, 0.68) or normal_fg
  local dim_target = vim.o.background == 'dark' and '#ffffff' or '#000000'
  local inactive_bg = blend(normal_bg, dim_target, 0.90) or normal_bg
  local inactive_cursor_bg = blend(cursor_bg, normal_bg, 0.55) or cursor_bg

  pcall(vim.api.nvim_set_hl, 0, 'CursorColumn', { bg = color_to_hex(color_column.bg) or cursor_bg })
  pcall(vim.api.nvim_set_hl, 0, 'CursorLineNr', { fg = normal_fg, bold = true })
  pcall(vim.api.nvim_set_hl, 0, 'StatusLine', { fg = normal_fg, bg = accent_bg, bold = true })
  pcall(vim.api.nvim_set_hl, 0, 'StatusLineNC', { fg = inactive_fg, bg = inactive_cursor_bg })
  pcall(vim.api.nvim_set_hl, 0, 'MiniStatuslineInactive', { fg = inactive_fg, bg = inactive_cursor_bg })
  pcall(vim.api.nvim_set_hl, 0, 'InactiveWindow', { fg = inactive_fg, bg = inactive_bg })
  pcall(vim.api.nvim_set_hl, 0, 'InactiveCursorLine', { bg = inactive_cursor_bg })
  pcall(vim.api.nvim_set_hl, 0, 'InactiveCursorColumn', { bg = inactive_cursor_bg })
  pcall(vim.api.nvim_set_hl, 0, 'InactiveCursorLineNr', { fg = inactive_fg })
  pcall(vim.api.nvim_set_hl, 0, 'InactiveEndOfBuffer', { fg = inactive_bg, bg = inactive_bg })
end

local function apply_window_focus()
  local current = vim.api.nvim_get_current_win()

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      if vim.w[win].focus_base_winhighlight == nil then
        vim.w[win].focus_base_winhighlight = strip_focus_winhighlight(get_winhl(win))
      end

      local parsed = parse_winhighlight(vim.w[win].focus_base_winhighlight)

      if win ~= current then
        parsed.Normal = 'InactiveWindow'
        parsed.NormalNC = 'InactiveWindow'
        parsed.CursorLine = 'InactiveCursorLine'
        parsed.CursorColumn = 'InactiveCursorColumn'
        parsed.CursorLineNr = 'InactiveCursorLineNr'
        parsed.EndOfBuffer = 'InactiveEndOfBuffer'
      end

      set_winhl(win, format_winhighlight(parsed))
    end
  end
end

local function refresh_window_focus()
  set_focus_highlights()
  apply_window_focus()
end

vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter', 'WinEnter', 'WinLeave', 'BufWinEnter', 'TermOpen' }, {
  group = focus_group,
  callback = vim.schedule_wrap(apply_window_focus),
})
vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
  group = focus_group,
  callback = vim.schedule_wrap(refresh_window_focus),
})
vim.api.nvim_create_autocmd('OptionSet', {
  group = focus_group,
  pattern = 'background',
  callback = vim.schedule_wrap(refresh_window_focus),
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
