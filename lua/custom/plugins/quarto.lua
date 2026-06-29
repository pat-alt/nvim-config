return {
  {
    'quarto-dev/quarto-nvim',
    opts = {
      lspFeatures = {
        enabled = true,
        chunks = 'curly',
        languages = { 'julia', 'python', 'bash', 'r' },
        diagnostics = {
          enabled = true,
          triggers = { 'BufWritePost' },
        },
        completion = {
          enabled = false,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = 'slime',
      },
    },
    -- BUG: For some reason slime (?) inserts extra tokens (']',')') in some cases.
    config = function(_, opts)
      require('quarto').setup(opts)

      local runner = require 'quarto.runner'
      vim.keymap.set('n', '<C-c>c', runner.run_cell, { desc = 'run cell', silent = true })
      vim.keymap.set('n', '<C-c>a', runner.run_above, { desc = 'run cell and above', silent = true })
      vim.keymap.set('n', '<C-c>A', runner.run_all, { desc = 'run all cells', silent = true })
      vim.keymap.set('n', '<C-c>l', function()
        runner.run_line()
        vim.cmd 'normal! j'
      end, { desc = 'run line', silent = true })
      local function run_visual_range()
        local start_line = vim.fn.line "'<"
        local end_line = vim.fn.line "'>"
        if start_line > end_line then
          start_line, end_line = end_line, start_line
        end

        runner.run_range()
        vim.schedule_wrap(function()
          vim.api.nvim_win_set_cursor(0, { end_line, 0 })
        end)()
      end

      vim.keymap.set('x', '<C-c>r', run_visual_range, { desc = 'run visual range', silent = true })
      vim.keymap.set('x', '<C-c><C-c>', run_visual_range, { desc = 'run visual range', silent = true })
      -- vim.keymap.set('n', '<C-c>RA', function()
      --   runner.run_all(true)
      -- end, { desc = 'run all cells of all languages', silent = true })

      -- quarto-nvim's ftplugin activates Otter using the lspFeatures options above.
    end,
    dependencies = {
      'jmbuhr/otter.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },

  {
    'jpalardy/vim-slime',
    dev = false,
    init = function()
      vim.g.slime_target = 'tmux'
      vim.g.slime_bracketed_paste = 1
      -- vim.g.slime_default_config = {"socket_name" = "default", "target_pane" = "{last}"}
      vim.g.slime_default_config = {
        -- Lua doesn't have a string split function!
        socket_name = vim.api.nvim_eval 'get(split($TMUX, ","), 0)',
        target_pane = '{right}',
      }
    end,
    config = function()
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = true
      vim.b.slime_cell_delimiter = '```'
      local function mark_terminal()
        local job_id = vim.b.terminal_job_id
        vim.print('job_id: ' .. job_id)
      end

      local function set_terminal()
        vim.fn.call('slime#config', {})
      end
      vim.keymap.set('n', '<leader>cm', mark_terminal, { desc = '[m]ark terminal' })
      vim.keymap.set('n', '<leader>cs', set_terminal, { desc = '[s]et terminal' })
    end,
  },
}
