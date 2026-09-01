return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    keywords = {
      REVIEW = { icon = " ", color = "#eab308" },
      AI = { icon = " ", color = "#7c3aed" },
      ponytail = { icon = " ", color = "#0891b2", alt = { "PONYTAIL" } },
    },
    highlight = {
      comments_only = false,
    },
  },
}
