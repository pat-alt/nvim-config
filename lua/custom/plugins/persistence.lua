return {
  'folke/persistence.nvim',
  event = 'BufReadPre', -- this will only start session saving when an actual file was opened
  opts = {},
  init = function()
    vim.api.nvim_create_autocmd('VimEnter', {
      nested = true,
      callback = function()
        if vim.fn.argc() == 0 then
          require('persistence').load()
        end
      end,
    })
  end,
}
