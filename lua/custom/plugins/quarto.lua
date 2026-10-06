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
          enabled = true,
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
        -- '< and '> are only committed once the selection ENDS, so during this
        -- visual-mode mapping they are stale or unset (0). Read the live
        -- selection instead: 'v' is its start, '.' the cursor at its end.
        local start_line = vim.fn.line 'v'
        local end_line = vim.fn.line '.'
        if start_line > end_line then
          start_line, end_line = end_line, start_line
        end

        -- Leave visual mode now, synchronously ('x' executes immediately).
        -- If visual mode is still active after the send, its exit resets the
        -- cursor to the selection start, clobbering any cursor fix-up below.
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

        -- Outside quarto files otter has no code chunks, so runner.run_range()
        -- errors with "No code chunks found". Send the selected lines straight
        -- to the REPL via vim-slime's native range send instead.
        if require('otter.keeper').rafts[vim.api.nvim_get_current_buf()] == nil then
          vim.fn['slime#send_range'](start_line, end_line)
        else
          runner.run_range()
        end
        -- Synchronous (not vim.schedule): a deferred set_cursor runs while
        -- visual mode is still up and gets undone by its exit-cursor reset.
        -- One line below the range, clamped to the buffer end.
        local last = math.min(end_line + 1, vim.api.nvim_buf_line_count(0))
        vim.api.nvim_win_set_cursor(0, { last, 0 })
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

      -- Disable slime's default mappings: its x-mode <C-c><C-c> (plugin/
      -- slime.vim) would overwrite run_visual_range set in the quarto config
      -- above, because slime's plugin script loads after quarto's config.
      -- The n-mode defaults we care about are re-added in config below.
      vim.g.slime_no_mappings = 1

      -- Auto-detect target based on which multiplexer nvim runs in.
      -- $TMUX is set by tmux for the processes it manages; $HERDR_PANE_ID is
      -- injected by herdr into every managed pane process and is INHERITED by
      -- nested multiplexers (e.g. tmux started from a herdr pane). So check
      -- tmux first: it is the innermost multiplexer actually enclosing nvim.
      -- Never default herdr's target_pane to $HERDR_PANE_ID: that is the pane
      -- nvim itself runs in, so sends would type the code into nvim.
      if vim.env.TMUX and vim.env.TMUX ~= '' then
        vim.g.slime_target = 'tmux'
        vim.g.slime_default_config = {
          socket_name = vim.fn.split(vim.env.TMUX, ',')[1],
          target_pane = '{right}',
        }
      elseif vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= '' then
        vim.g.slime_target = 'herdr'
        vim.g.slime_default_config = { target_pane = '' }
      else
        -- No multiplexer detected; use :SlimeSwitchTarget to pick one.
        vim.g.slime_target = 'tmux'
      end
    end,
    config = function()
      vim.b.slime_cell_delimiter = '```'

      -- Restore the slime defaults worth keeping (slime_no_mappings = 1 above).
      vim.keymap.set('n', '<C-c><C-c>', '<Plug>SlimeParagraphSend', { remap = true, silent = true, desc = 'send paragraph to REPL' })
      vim.keymap.set('n', '<C-c>v', '<Plug>SlimeConfig', { remap = true, silent = true, desc = 'slime config' })

      --- Apply vim-slime globals for a given target.
      --- Used by :SlimeSwitchTarget and the init-time auto-detection.
      local function apply_target(target)
        if target == 'tmux' then
          vim.g.slime_target = 'tmux'
          vim.g.slime_default_config = {
            -- fall back to tmux's default socket when nvim itself is not in tmux
            socket_name = (vim.env.TMUX and vim.env.TMUX ~= '') and vim.fn.split(vim.env.TMUX, ',')[1] or 'default',
            target_pane = '{right}',
          }
        elseif target == 'herdr' then
          vim.g.slime_target = 'herdr'
          -- empty default: prompts for the real REPL pane on first send
          vim.g.slime_default_config = { target_pane = '' }
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
