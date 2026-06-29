return {
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewRefresh',
      'DiffviewFileHistory',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = '[D]iff working tree' },
      { '<leader>gD', '<cmd>DiffviewOpen HEAD<cr>', desc = '[D]iff against HEAD' },
      { '<leader>gf', '<cmd>DiffviewToggleFiles<cr>', desc = 'Toggle diffview [f]iles' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File [h]istory' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Repo [H]istory' },
      { '<leader>gq', '<cmd>DiffviewClose<cr>', desc = '[Q]uit diffview' },
      { '<leader>gr', '<cmd>DiffviewRefresh<cr>', desc = '[R]efresh diffview' },
    },
    config = function(_, opts)
      require('diffview').setup(opts)

      local function set_diffview_hl()
        local function blend(color, alpha)
          local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
          local bg = normal.bg or 0
          local fg = tonumber(color:sub(2), 16)
          local r = math.floor(((fg / 0x10000) % 0x100) * alpha + ((bg / 0x10000) % 0x100) * (1 - alpha))
          local g = math.floor(((fg / 0x100) % 0x100) * alpha + ((bg / 0x100) % 0x100) * (1 - alpha))
          local b = math.floor((fg % 0x100) * alpha + (bg % 0x100) * (1 - alpha))

          return string.format('#%02x%02x%02x', r, g, b)
        end

        local add_bg = blend('#22c55e', 0.25)
        local change_bg = blend('#eab308', 0.25)

        vim.api.nvim_set_hl(0, 'DiffviewStatusAdded', { fg = '#22c55e', bold = true })
        vim.api.nvim_set_hl(0, 'DiffviewStatusUntracked', { fg = '#22c55e', bold = true })
        vim.api.nvim_set_hl(0, 'DiffviewFilePanelInsertions', { fg = '#22c55e', bold = true })
        vim.api.nvim_set_hl(0, 'DiffviewStatusModified', { fg = '#eab308', bold = true })
        vim.api.nvim_set_hl(0, 'DiffviewDiffAdd', { bg = add_bg })
        vim.api.nvim_set_hl(0, 'DiffviewDiffChange', { bg = change_bg })
        vim.api.nvim_set_hl(0, 'DiffviewDiffText', { bg = change_bg })
        vim.api.nvim_set_hl(0, 'DiffAdd', { bg = add_bg })
        vim.api.nvim_set_hl(0, 'DiffChange', { bg = change_bg })
        vim.api.nvim_set_hl(0, 'DiffText', { bg = change_bg })
      end

      set_diffview_hl()
      vim.api.nvim_create_autocmd('ColorScheme', { callback = set_diffview_hl })
    end,
    opts = {
      enhanced_diff_hl = true,
      show_help_hints = true,
      view = {
        default = {
          layout = 'diff2_horizontal',
          winbar_info = true,
        },
        file_history = {
          layout = 'diff2_horizontal',
          winbar_info = true,
        },
        merge_tool = {
          layout = 'diff3_horizontal',
          disable_diagnostics = true,
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = 'tree',
        win_config = {
          position = 'left',
          width = 35,
        },
      },
      hooks = {
        diff_buf_read = function()
          vim.opt_local.wrap = false
          vim.opt_local.list = false
        end,
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
