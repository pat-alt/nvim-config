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
    init = function()
      vim.g.slime_bracketed_paste = 1

      -- Auto-detect target based on which multiplexer nvim runs in.
      -- $HERDR_PANE_ID is injected by herdr into every managed pane process;
      -- $TMUX is set by tmux. The first match wins.
      if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= '' then
        vim.g.slime_target = 'herdr'
        vim.g.slime_default_config = { target_pane = vim.env.HERDR_PANE_ID }
      elseif vim.env.TMUX and vim.env.TMUX ~= '' then
        vim.g.slime_target = 'tmux'
        vim.g.slime_default_config = {
          socket_name = vim.api.nvim_eval 'get(split($TMUX, ","), 0)',
          target_pane = '{right}',
        }
      else
        -- No multiplexer detected; use :SlimeSwitchTarget to pick one.
        vim.g.slime_target = 'tmux'
      end
    end,
    config = function()
      vim.b.slime_cell_delimiter = '```'

      --- Apply vim-slime globals for a given target.
      --- Used by :SlimeSwitchTarget and the init-time auto-detection.
      local function apply_target(target)
        if target == 'herdr' then
          vim.g.slime_target = 'herdr'
          vim.g.slime_default_config = { target_pane = vim.env.HERDR_PANE_ID or '' }
        elseif target == 'tmux' then
          vim.g.slime_target = 'tmux'
          vim.g.slime_default_config = {
            socket_name = vim.api.nvim_eval 'get(split($TMUX, ","), 0)',
            target_pane = '{right}',
          }
        else
          return false
        end
        return true
      end

      vim.api.nvim_create_user_command('SlimeSwitchTarget', function(opts)
        local target = opts.args
        if not apply_target(target) then
          vim.notify('Unknown slime target: ' .. target, vim.log.levels.ERROR)
          return
        end
        -- Clear buffer-local config so vim-slime re-prompts on next send.
        vim.b.slime_config = nil
        vim.notify('Slime target: ' .. target, vim.log.levels.INFO)
      end, {
        nargs = 1,
        complete = function() return { 'herdr', 'tmux' } end,
      })

      -- Re-configure the current target (pane id, socket, etc.).
      -- Pre-fills with the current value; edit it and press Enter.
      vim.keymap.set('n', '<leader>cs', '<cmd>SlimeConfig<cr>', { desc = '[s]et slime config' })

      -- Reset the target pane from scratch: clears the remembered config
      -- and re-prompts, so the old pane ID is not pre-filled.
      vim.api.nvim_create_user_command('SlimeSetPane', function()
        vim.b.slime_config = nil
        vim.cmd 'SlimeConfig'
      end, {})
      vim.keymap.set('n', '<leader>cp', '<cmd>SlimeSetPane<cr>', { desc = 'set slime [p]ane' })

      -- Toggle between herdr and tmux.
      vim.keymap.set('n', '<leader>cS', function()
        local current = vim.g.slime_target or 'tmux'
        local other = current == 'herdr' and 'tmux' or 'herdr'
        vim.cmd('SlimeSwitchTarget ' .. other)
      end, { desc = '[S]witch slime target' })

      -- Debug helper: print the current terminal job id (neovim terminals only).
      vim.keymap.set('n', '<leader>cm', function()
        local job_id = vim.b.terminal_job_id
        vim.notify('job_id: ' .. tostring(job_id))
      end, { desc = '[m]ark terminal' })
    end,
  },
}
