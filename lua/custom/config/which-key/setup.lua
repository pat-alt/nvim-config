local wk = require 'which-key'

require 'custom.config.which-key.code'

-- normal mode
wk.add({
  { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
  { '<leader>d', group = '[D]ocument' },
  { '<leader>g', group = '[G]it' },
  { '<leader>s', group = '[S]earch' },
  { '<leader>w', group = '[W]orkspace' },
  { '<leader>t', group = '[T]oggle' },
  { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  { '<leader>z', ':ZenMode<cr>', desc = '[Z]en mode' },
  { '<leader>m', ':Mtm<cr>', desc = '[M]arkdown table mode' },
  -- Toggle
  { '<leader>te', ':lua require("nabla").popup()<CR>', desc = '[E]quation' },
  {
    '<leader>td',
    function()
      if vim.o.background == 'light' then
        vim.o.background = 'dark'
      else
        vim.o.background = 'light'
      end
    end,
    desc = '[d]ark theme',
  },
  -- Search
  { '<leader>st', ':TodoTelescope<cr>', desc = '[T]odo' },
  { '<leader>sp', ':Papis search<cr>', desc = '[P]apis' },
  -- Search and Replace
  { '<leader>r', group = '[R]eplace' },
  { '<leader>rf', [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], desc = 'Search and replace in [f]ile' },
  -- Quarto
  { '<leader>q', group = '[q]uarto' },
  { '<leader>qh', ':QuartoHelp ', desc = '[h]elp' },
  { '<leader>qf', ":lua require'quarto'.quartoPreview({ args = '--port 4242 --no-browser' })<cr>", desc = '[f]ixed port preview' },
  { '<leader>qq', ':QuartoClosePreview<cr>', desc = '[q]uit preview' },
  { '<leader>qp', ':QuartoPreview<cr>', desc = '[p]review' },
  -- Vim
  { '<leader>v', group = '[v]im' },
  { '<leader>vc', ':Telescope colorscheme<cr>', desc = '[c]olortheme' },
  { '<leader>vl', ':Lazy<cr>', desc = '[L]azy' },
  -- Mason
  { '<leader>vm', group = '[M]ason' },
  { '<leader>vmo', ':Mason<cr>', desc = '[O]pen' },
  { '<leader>vmi', ':MasonInstall ', desc = '[I]nstall' },
  -- Persistence
  { '<leader>vp', group = '[P]ersistence' },
  {
    '<leader>vps',
    function()
      require('persistence').select()
    end,
    desc = '[s]elect',
  },
  {
    '<leader>vpl',
    function()
      require('persistence').load()
    end,
    desc = '[l]oad',
  },
  -- Insert comments
  { '<leader>i', group = '[I]nsert' },
  -- AI (CodeCompanion) — group only, keymaps registered in plugin config
  { '<leader>a', group = '[A]I', mode = { 'n', 'v' } },
}, { mode = 'n' })
