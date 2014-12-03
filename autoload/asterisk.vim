"=============================================================================
" FILE: autoload/asterisk.vim
" AUTHOR: haya14busa
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

let s:TRUE = !0
let s:FALSE = 0
let s:INT = { 'MAX': 2147483647 }
let s:DIRECTION = { 'forward': 1, 'backward': 0 } " see :h v:searchforward

" do_jump: do not move cursor
" is_whole: is_whole word. false if `g` flag given (e.g. * -> true, g* -> false)
let s:_config = {
\   'direction' : s:DIRECTION.forward,
\   'do_jump' : s:TRUE,
\   'is_whole' : s:TRUE
\ }

function! s:default_config() abort
    return deepcopy(s:_config)
endfunction

" @return command: String
function! asterisk#do(mode, config) abort
    let config = extend(s:default_config(), a:config)
    let pattern = (s:is_visual(a:mode) ?
    \   s:convert_2_word_pattern(s:get_selected_text(), config) : s:cword_pattern(config))
    if s:is_empty_cword(pattern) " 'E348: No string under cursor'
        if s:is_visual(a:mode)
            return "\<Esc>:echohl ErrorMsg | echom 'asterisk.vim: No selected string' | echohl None\<CR>"
        else
            return '*'
        endif
    endif
    let should_plus_one_count = s:should_plus_one_count(pattern, config, a:mode)
    let maybe_count = (should_plus_one_count ? string(v:count1 + 1) : '')
    let pre = (s:is_visual(a:mode) || should_plus_one_count ? "\<Esc>" . maybe_count : '')
    if config.do_jump
        let key = (config.direction is s:DIRECTION.forward ? '/' : '?')
        return pre . key . pattern . "\<CR>"
    else
        call s:set_search(pattern)
        " :h function-search-undo
        " :h v:searchforward
        let hlsearch = 'let &hlsearch=&hlsearch'
        let searchforward = printf('let v:searchforward = %d', config.direction)
        let echo = printf("echo '%s'", pattern)
        return printf("%s:\<C-u>%s | %s | %s\<CR>", pre, hlsearch, searchforward, echo)
    endif
endfunction

" @return cword: String
function! s:cword_pattern(config) abort
    return printf((a:config.is_whole ? '\<%s\>' : '%s'), expand('<cword>'))
endfunction

" This function is based on https://github.com/thinca/vim-visualstar
" Author  : thinca <thinca+vim@gmail.com>
" License : zlib License
" @return selected_pattern: String
function! s:convert_2_word_pattern(pattern, config) abort
    let text = a:pattern
    let type = (a:config.direction is# s:DIRECTION.forward ? '/' : '?')
    let [pre, post] = ['', '']
    if a:config.is_whole
        let head = matchstr(text, '^.')
        let is_head_multibyte = 1 < len(head)
        let [l, col] = getpos("'<")[1 : 2]
        let line = getline(l)
        let before = line[: col - 2]
        let outer = matchstr(before, '.$')
        if text =~# '^\k' && ((!empty(outer) && len(outer) != len(head)) ||
        \   (!is_head_multibyte && (col == 1 || before !~# '\k$')))
            let pre = '\<'
        endif
        let tail = matchstr(text, '.$')
        let is_tail_multibyte = 1 < len(tail)
        let [l, col] = getpos("'>")[1 : 2]
        let col += len(tail) - 1
        let line = getline(l)
        let after = line[col :]
        let outer = matchstr(after, '^.')
        if text =~# '\k$' && ((!empty(outer) && len(outer) != len(tail)) ||
        \   (!is_tail_multibyte && (col == len(line) || after !~# '^\k')))
            let post = '\>'
        endif
    endif
    let text = substitute(escape(text, '\' . type), "\n", '\\n', 'g')
    return '\V' . pre . text . post
endfunction

function! s:is_empty_cword(pattern) abort
    return a:pattern =~# '\m^\%(\\V\)\=\%(\\<\\>\)\=$'
endfunction

" @return nothing
function! s:set_search(pattern, ...) abort
    let @/ = a:pattern
    call histadd('/', @/)
endfunction

" @return boolean
function! s:should_plus_one_count(pattern, config, mode) abort
    " For backward only because count isn't needed with <expr> but it requires
    " +1 for backward and for the case that cursor is not at the head of
    " pattern
    return a:config.direction is# s:DIRECTION.backward && ! s:is_head_of_cword(a:pattern)
    \   || (!s:is_visual(a:mode) && s:get_pos_char() !~# '\k')
endfunction

" @return boolean
function! s:is_head_of_cword(pattern) abort
    let c = col('.')
    return a:pattern is# getline(line('.'))[c - 1 : c + strlen(a:pattern) - 2]
endfunction

" Assume the current mode is middle of visual mode.
" @return selected text
function! s:get_selected_text(...) abort
    let mode = get(a:, 1, mode(1))
    let end_curswant = winsaveview().curswant + 1
    let current_pos = [line('.'), end_curswant < 0 ? s:INT.MAX : end_curswant ]
    let other_end_pos = [line('v'), col('v')]
    let [begin, end] = s:sort_pos([current_pos, other_end_pos])
    if mode ==# "\<C-v>"
        let [min_c, max_c] = s:sort_num([begin[1], end[1]])
        let lines = map(range(begin[0], end[0]), "
        \   getline(v:val)[min_c - 1 : max_c - 1]
        \ ")
    elseif mode ==# "V"
        let lines = getline(begin[0], end[0])
    else
        if begin[0] ==# end[0]
            let lines = [getline(begin[0])[begin[1]-1 : end[1]-1]]
        else
            let lines = [getline(begin[0])[begin[1]-1 :]]
            \         + (end[0] - begin[0] < 2 ? [] : getline(begin[0]+1, end[0]-1))
            \         + [getline(end[0])[: end[1]]]
        endif
    endif
    return join(lines, "\n") . (mode ==# "V" ? "\n" : '')
endfunction

" Helper:

function! s:is_visual(mode) abort
    return a:mode =~# "[vV\<C-v>]"
endfunction

function! s:get_pos_char()
    return getline('.')[col('.')-1]
endfunction

function! s:sort_num(xs) abort
    " 7.4.341
    " http://ftp.vim.org/vim/patches/7.4/7.4.341
    if v:version > 704 || v:version == 704 && has('patch341')
        return sort(a:xs, 'n')
    else
        return sort(a:xs, 's:_sort_num_func')
    endif
endfunction

function! s:_sort_num_func(x, y) abort
    return a:x - a:y
endfunction

function! s:sort_pos(pos_list) abort
    " pos_list: [ [x1, y1], [x2, y2] ]
    return sort(a:pos_list, 's:compare_pos')
endfunction

function! s:compare_pos(x, y) abort
    return max([-1, min([1,(a:x[0] == a:y[0]) ? a:x[1] - a:y[1] : a:x[0] - a:y[0]])])
endfunction

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" __END__  {{{
" vim: expandtab softtabstop=4 shiftwidth=4
" vim: foldmethod=marker
" }}}
