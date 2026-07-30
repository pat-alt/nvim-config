return {
  'nickjvandyke/opencode.nvim',
  version = '*',
  dependencies = {
    {
      'folke/snacks.nvim',
      opts = {
        input = {},
        picker = {
          actions = {
            opencode_send = function(...)
              return require('opencode').snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ['<a-a>'] = { 'opencode_send', mode = { 'n', 'i' } },
              },
            },
          },
        },
        terminal = {},
      },
    },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {}
    local curl_supports_fail_with_body = vim.system({ 'curl', '--fail-with-body', '--version' }):wait().code == 0
    local pixicurl = vim.fn.expand('~/.pixi/bin/pixicurl')
    if not curl_supports_fail_with_body and vim.fn.executable(pixicurl) == 1 and vim.fn.has('unix') == 1 then
      local shim_dir = vim.fn.stdpath('cache') .. '/opencode-curl'
      local curl = shim_dir .. '/curl'
      vim.fn.mkdir(shim_dir, 'p')
      if vim.uv.fs_readlink(curl) ~= pixicurl then
        vim.fn.delete(curl)
        vim.uv.fs_symlink(pixicurl, curl)
      end
      vim.env.PATH = shim_dir .. ':' .. vim.env.PATH
    end

    vim.o.autoread = true

  end,
}
