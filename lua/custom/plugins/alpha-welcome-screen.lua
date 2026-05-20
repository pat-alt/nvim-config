return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'
    dashboard.section.buttons.val = {
      dashboard.button('e', '  > New file', ':ene <BAR> startinsert <CR>'),
      dashboard.button('f', '󰈞  > Find file', ':Telescope find_files<CR>'),
      dashboard.button('r', '  > Recent', ':Telescope oldfiles<CR>'),
      dashboard.button('s', '  > Settings', ':e $MYVIMRC | :cd %:p:h<cr>'),
      dashboard.button('o', '  > Toggle OpenCode', ':lua require("opencode").toggle()<CR>'),
      dashboard.button('q', '󰅚  > Quit NVIM', ':qa<CR>'),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)
  end,
}
