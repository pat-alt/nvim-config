return {
  'carlos-algms/agentic.nvim',
  opts = {
    provider = 'opencode-acp',
    acp_providers = {
      ['opencode-acp'] = {
        args = { 'acp' },
      },
    },
  },
  keys = {
    {
      '<leader>ao',
      function()
        require('agentic').toggle()
      end,
      mode = { 'n', 't' },
      desc = 'Agentic toggle',
    },
    {
      '<leader>aO',
      function()
        require('agentic').add_selection_or_file_to_context()
      end,
      mode = { 'n', 'x' },
      desc = 'Agentic add selection or file',
    },
    {
      '<leader>ab',
      function()
        require('agentic').add_file()
      end,
      mode = { 'n', 'x' },
      desc = 'Agentic add current file',
    },
    {
      '<leader>af',
      function()
        require('agentic').add_buffer_diagnostics()
      end,
      mode = { 'n', 'x' },
      desc = 'Agentic add buffer diagnostics',
    },
    {
      '<leader>ax',
      function()
        require('agentic').restore_session()
      end,
      mode = { 'n', 'x' },
      desc = 'Agentic restore session',
    },
    {
      '<leader>an',
      function()
        require('agentic').new_session()
      end,
      desc = 'Agentic new session',
    },
    {
      '<leader>ad',
      function()
        require('agentic.session_registry').destroy_session()
      end,
      desc = 'Agentic close current session',
    },
    {
      '<leader>aq',
      function()
        require('agentic').stop_generation()
      end,
      desc = 'Agentic stop generation',
    },
  },
}
