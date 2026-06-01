return {
  'NickvanDyke/opencode.nvim',
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
    vim.g.opencode_opts = {}

    -- Required for OpenCode's file reload integration.
    vim.o.autoread = true

    vim.keymap.set({ 'n', 't' }, '<leader>ao', function()
      require('opencode').toggle()
    end, { desc = 'OpenCode toggle' })

    vim.keymap.set({ 'n', 'x' }, '<leader>aO', function()
      require('opencode').ask('@this: ', { submit = true })
    end, { desc = 'OpenCode ask with context' })

    vim.keymap.set({ 'n', 'x' }, '<leader>ab', function()
      require('opencode').ask('@buffer: ')
    end, { desc = 'OpenCode ask current buffer' })

    vim.keymap.set({ 'n', 'x' }, '<leader>af', function()
      require('opencode').ask('@quickfix: ')
    end, { desc = 'OpenCode ask quickfix list' })

    vim.keymap.set({ 'n', 'x' }, '<leader>ax', function()
      require('opencode').select()
    end, { desc = 'OpenCode actions' })

    vim.keymap.set('n', '<leader>an', function()
      require('opencode').command('session.new')
    end, { desc = 'OpenCode new session' })

    vim.keymap.set('n', '<leader>aq', function()
      require('opencode').command('session.interrupt')
    end, { desc = 'OpenCode interrupt' })

    vim.keymap.set({ 'n', 'x' }, 'go', function()
      return require('opencode').operator('@this ')
    end, { desc = 'Add range to OpenCode', expr = true })

    vim.keymap.set('n', 'goo', function()
      return require('opencode').operator('@this ') .. '_'
    end, { desc = 'Add line to OpenCode', expr = true })
  end,
}
