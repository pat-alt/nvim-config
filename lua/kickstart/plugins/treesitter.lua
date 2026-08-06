return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    tag = 'v0.10.0', -- pin: latest HEAD requires tree-sitter CLI (GLIBC 2.35+)
    build = ':TSUpdate',
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'julia', 'r', 'python', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      -- Fix: nvim-treesitter v0.10.0's set-lang-from-info-string! directive is
      -- incompatible with Neovim 0.11+ where match[capture_id] returns TSNode[]
      -- instead of a single TSNode. This causes "attempt to call method 'range'
      -- (a nil value)" errors when processing markdown code block injections.
      local query = require('vim.treesitter.query')
      local non_filetype_aliases = {
        ex = 'elixir', pl = 'perl', sh = 'bash', uxn = 'uxntal', ts = 'typescript',
      }
      local function resolve_lang(alias)
        return vim.filetype.match { filename = 'a.' .. alias } or non_filetype_aliases[alias] or alias
      end
      query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
        local nodes = match[pred[2]]
        if not nodes then return end
        local node = type(nodes) == 'table' and nodes[1] or nodes
        if not node then return end
        metadata['injection.language'] = resolve_lang(vim.treesitter.get_node_text(node, bufnr):lower())
      end, { force = true, all = false })
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        init = function()
          -- Disable entire built-in ftplugin mappings to avoid conflicts.
          -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
          vim.g.no_plugin_maps = true

          -- Or, disable per filetype (add as you like)
          -- vim.g.no_python_maps = true
          -- vim.g.no_ruby_maps = true
          -- vim.g.no_rust_maps = true
          -- vim.g.no_go_maps = true
        end,
        config = function()
          require('nvim-treesitter-textobjects').setup {
            select = {
              -- Automatically jump forward to textobj, similar to targets.vim
              lookahead = true,
            },
          }

          -- move
          vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
            require('nvim-treesitter-textobjects.move').goto_next_start('@code_cell.inner', 'textobjects')
          end, { desc = 'Jump to next block' })
          vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
            require('nvim-treesitter-textobjects.move').goto_previous_start('@code_cell.inner', 'textobjects')
          end, { desc = 'Jump to previous block' })
          -- methods
          vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
            require('nvim-treesitter-textobjects.move').goto_next_end('@function.inner', 'textobjects')
          end, { desc = 'Jump to start of next [m]ethod' })
          vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
            require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
          end, { desc = 'Jump to end of next [m]ethod' })
          vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
            require('nvim-treesitter-textobjects.move').goto_previous_end('@function.inner', 'textobjects')
          end, { desc = 'Jump to start of previous [m]ethod' })
          vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
            require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
          end, { desc = 'Jump to end of previous [m]ethod' })
        end,
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
