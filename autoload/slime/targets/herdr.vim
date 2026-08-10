" vim-slime target for herdr (https://herdr.dev/)
"
" Sends text to a herdr pane via the `herdr pane send-text` / `send-keys` CLI.
" Herdr injects $HERDR_PANE_ID into managed pane processes, so when nvim runs
" inside herdr the target pane auto-fills. Otherwise the user is prompted once
" (e.g. "w1:p1") and vim-slime remembers it per-buffer.
"
" Config keys (b:slime_config):
"   target_pane   string   public pane id, e.g. "w1:p1"

function! slime#targets#herdr#config() abort
  if !exists("b:slime_config")
    let l:default_pane = ""
    if exists("$HERDR_PANE_ID") && $HERDR_PANE_ID !=# ""
      let l:default_pane = $HERDR_PANE_ID
    endif
    let b:slime_config = {"target_pane": l:default_pane}
  endif
  let b:slime_config["target_pane"] = input("herdr target pane (e.g. w1:p1): ", b:slime_config["target_pane"])
endfunction

function! slime#targets#herdr#send(config, text)
  let l:pane = a:config["target_pane"]
  let [l:bp, l:text_to_paste, l:has_crlf] = slime#common#bracketed_paste(a:text)

  if len(l:text_to_paste) == 0 && !l:has_crlf
    return
  endif

  if l:bp
    call s:send_checked("herdr pane send-text %s %s", [l:pane, "\e[200~"])
  endif

  let l:chunk_size = 1000
  let l:total = strchars(l:text_to_paste)
  let l:i = 0
  while l:i * l:chunk_size < l:total
    let l:chunk = strcharpart(l:text_to_paste, l:i * l:chunk_size, l:chunk_size)
    call s:send_checked("herdr pane send-text %s %s", [l:pane, l:chunk])
    let l:i += 1
  endwhile

  if l:bp
    call s:send_checked("herdr pane send-text %s %s", [l:pane, "\e[201~"])
  endif

  if l:has_crlf
    call s:send_checked("herdr pane send-keys %s enter", [l:pane])
  endif
endfunction

function! slime#targets#herdr#ValidEnv() abort
  if !executable("herdr")
    call s:warn("herdr executable not found on PATH")
    return 0
  endif
  return 1
endfunction

function! slime#targets#herdr#ValidConfig(config, silent) abort
  if type(a:config) != v:t_dict
    if !a:silent | call s:warn("herdr config is not a dict") | endif
    return 0
  endif
  if empty(a:config)
    if !a:silent | call s:warn("herdr config is empty") | endif
    return 0
  endif
  if !has_key(a:config, "target_pane")
    if !a:silent | call s:warn("herdr config lacks 'target_pane'") | endif
    return 0
  endif
  if a:config["target_pane"] ==# ""
    if !a:silent | call s:warn("herdr target_pane is empty") | endif
    return 0
  endif
  return 1
endfunction

function! s:warn(msg)
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction

" Run a herdr CLI command, capturing stderr and surfacing failures.
" Unlike slime#common#system, this redirects stderr to stdout (2>&1) and
" checks v:shell_error so invalid pane IDs and other errors are visible.
function! s:send_checked(cmd_template, args)
  let l:escaped = map(copy(a:args), "shellescape(v:val)")
  let l:cmd = call('printf', [a:cmd_template] + l:escaped) . " 2>&1"
  let l:out = system(l:cmd)
  if v:shell_error != 0
    let l:msg = trim(l:out)
    if l:msg ==# ""
      let l:msg = "command failed (exit " . v:shell_error . ")"
    endif
    call s:warn("herdr: " . l:msg)
  endif
endfunction
