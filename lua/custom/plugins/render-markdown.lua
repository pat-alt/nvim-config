return {
  { 'jbyuki/nabla.nvim' },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      win_options = { conceallevel = { rendered = 2 } },
      on = {
        render = function()
          require('nabla').enable_virt { autogen = true }
        end,
        clear = function()
          require('nabla').disable_virt()
        end,
      },
    },
    config = function()
      require('render-markdown').setup {
        file_types = { 'markdown', 'quarto', 'AgenticChat' },
        html = {
          comment = { conceal = false },
        },
        latex = { enabled = false },
      }
    end,
  },
}
