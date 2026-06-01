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
