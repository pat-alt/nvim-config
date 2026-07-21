return {
  'carlos-algms/agentic.nvim',
  opts = {
    provider = 'opencode-acp',
    windows = {
      position = 'right',
      width = '40%',
    },
  },
  keys = {
    {
      '<leader>ao',
      function()
        require('agentic').toggle({ auto_add_to_context = false })
      end,
      mode = { 'n', 'v', 'i' },
      desc = 'Agentic toggle',
    },
    {
      '<leader>aO',
      function()
        require('agentic').open({ auto_add_to_context = true })
      end,
      mode = { 'n', 'v' },
      desc = 'Agentic open with context',
    },
    {
      '<leader>ab',
      function()
        require('agentic').add_file()
      end,
      mode = { 'n', 'v' },
      desc = 'Agentic add current file',
    },
    {
      '<leader>af',
      function()
        require('agentic').add_buffer_diagnostics()
      end,
      mode = { 'n' },
      desc = 'Agentic add buffer diagnostics',
    },
    {
      '<leader>an',
      function()
        require('agentic').new_session({ auto_add_to_context = false })
      end,
      mode = { 'n', 'v' },
      desc = 'Agentic new session',
    },
    {
      '<leader>aq',
      function()
        require('agentic').stop_generation()
      end,
      mode = { 'n', 'v', 'i' },
      desc = 'Agentic stop generation',
    },
    {
      '<leader>ar',
      function()
        require('agentic').restore_session()
      end,
      mode = { 'n', 'v', 'i' },
      desc = 'Agentic restore session',
    },
  },
}
