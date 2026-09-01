# Plan: todo-comments highlighting in diffview diff buffers

## Objective

Make todo-comments.nvim highlight REVIEW/AI keywords inside diffview.nvim diff
buffers, or determine it isn't feasible without hacks.

## Diagnosis (root cause found)

**This is feasible with a clean, supported API — no hacks needed.**

1. diffview creates diff buffers with `buftype = "nowrite"`:
   `~/.local/share/nvim/lazy/diffview.nvim/lua/diffview/vcs/file.lua:56-62`
   (`File.bufopts = { buftype = "nowrite", modifiable = false, ... }`).
   Exception: stage-0 index buffers get `buftype = nil` (file.lua:266-270), and
   LOCAL (working-tree) panes reuse the real file buffer via
   `_create_local_buffer()` (`vim.cmd("edit")`, file.lua:156-164) → `buftype = ""`.

2. todo-comments rejects those buffers in `is_valid_buf()`:
   `~/.local/share/nvim/lazy/todo-comments.nvim/lua/todo-comments/highlight.lua:308-319`
   — only `buftype == ""` or `"quickfix"` pass. `"nowrite"` → `false`.

3. `M.attach(win)` (highlight.lua:324-331) returns early when
   `not force and not M.is_valid_win(win)`. The current config calls
   `pcall(hl.attach)` **without** `force` — it succeeds silently and does
   nothing. That's why removing the error didn't produce highlights.

4. **The fix**: `M.attach(win, force)` has a built-in `force` parameter that
   bypasses the validity check (highlight.lua:329). This is a first-class API
   parameter, not monkey-patching. `M.highlight()` itself never checks buftype,
   and the extmark/sign machinery works on any buffer.

5. Hook timing: `diff_buf_read` is emitted inside `nvim_win_call(winid, ...)`
   (file.lua:144-148), and `diff_buf_win_enter` likewise
   (scene/window.lua:184-189). User hooks receive `(bufnr, winid, ctx)` for
   `diff_buf_win_enter` (forwarded via `config.user_emitter`, bootstrap.lua:51-54).
   So the winid is handed to us — no `vim.schedule` guessing needed.

## Constraints and assumptions

- `comments_only = false` is already set (required — treesitter/syntax state in
  diff buffers is unreliable for `is_comment`).
- `<leader>a` insertion only works in modifiable panes (working tree); the
  read-only panes just need highlighting, which this fix covers.
- Assumes diffview and todo-comments stay on these major versions; `force` is
  an undocumented-but-stable parameter (present since 2022).

## Recommended plan

One file, one hook change — `lua/custom/plugins/diffview.lua`:

1. Replace the `vim.schedule(...)` pcall block inside `diff_buf_read` with a
   separate `diff_buf_win_enter` hook that force-attaches:

   ```lua
   hooks = {
     diff_buf_read = function()
       vim.opt_local.wrap = true
       vim.opt_local.linebreak = true
       vim.opt_local.list = false
       vim.keymap.set('n', '<leader>a', function()
         -- ... unchanged ...
       end, { buffer = true, desc = 'Add REVIEW comment' })
     end,
     diff_buf_win_enter = function(bufnr, winid)
       local ok, hl = pcall(require, 'todo-comments.highlight')
       -- ponytail: force=true bypasses buftype check ("nowrite" diff buffers)
       if ok then pcall(hl.attach, winid, true) end
     end,
   },
   ```

   (Alternatively keep it in `diff_buf_read` and call `hl.attach(nil, true)` —
   the current window is the diff window there — but the explicit `winid` from
   `diff_buf_win_enter` is more robust.)

2. That's it. No changes to `todo-comments.lua`.

Known benign limitation (no action needed): todo's `on_lines` callback
re-checks `is_valid_buf` and detaches if the buffer's lines change
(highlight.lua:353-356). Diff buffers are written once at creation (before the
hook fires), so this only triggers on `DiffviewRefresh`/re-open — which
re-fires the hook and re-attaches. Self-healing.

## Verification

1. `nvim` → `:DiffviewOpen` → open a file whose HEAD version (left pane)
   contains a `TODO:`/`REVIEW:` comment → keyword should be highlighted in both
   panes.
2. With cursor in the left pane: `<leader>a` should still insert a REVIEW
   comment in the modifiable right pane only (unchanged behavior).
3. Programmatic check in the diff buffer:
   `:lua print(vim.bo.buftype, require('todo-comments.highlight').bufs[vim.api.nvim_get_current_buf()])`
   → expect `nowrite  true`.
4. `:DiffviewRefresh` → highlights should reappear (hook re-fires).

## Risks and mitigations

- **Risk**: `force` is undocumented; a todo-comments update could rename it.
  **Mitigation**: call is wrapped in `pcall` — worst case it fails silently
  back to current behavior. Pinned by lazy-lockfile anyway.
- **Risk**: signs (`sign_place`) also appear in diff buffers. They work on
  `nowrite` buffers; if unwanted in the gutter, that's a separate cosmetic
  toggle — leave as-is unless it bothers you.

## Optional fallback plan

If `force` ever disappears: call `require('todo-comments.highlight').highlight(bufnr, 0, -1)`
directly from the hook (it never checks buftype), plus a `BufWinEnter`
buffer-local autocmd for re-highlight on scroll edits. Hackier, loses live
`on_lines` updates — only reach for it if the primary fix breaks.
