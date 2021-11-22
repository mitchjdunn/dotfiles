call plug#begin('~/.config/nvim/plugged')
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 't9md/vim-choosewin'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/Tabmerge'
Plug 'godlygeek/tabular'
Plug 'ryvnf/readline.vim'
Plug 'pangloss/vim-javascript'
Plug 'plasticboy/vim-markdown'
Plug 'chriskempson/base16-vim'
call plug#end()

" Confluence push
nnoremap <leader>xp :w<cr>:echo system("confluence-push <c-r>%")<cr>:e<cr>

" FZF settings
let g:fzf_excludes =
\ [ '*Library*',
  \ '*.git*',
  \ '*.npm*',
  \ '*node_modules*',
  \ '*Music*',
  \ '/Users/dunmi001/.m2*',
  \ '/Users/dunmi001/.wine*',
  \ '/Users/dunmi001/.dbeaver*',
  \ '/Users/dunmi001/.azure*',
  \ '/Users/dunmi001/.eclipse*',
  \ '/Users/dunmi001/.docker*',
  \ '/Users/dunmi001/.config/nvim/plugged*',
  \ '/Users/dunmi001/.config/configstore*',
  \ '/Users/dunmi001/.config/base16-shell*',
  \ '/Users/dunmi001/.config/karabiner*',
  \ '/Users/dunmi001/.config/nvim/undo*' ]
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Statement'],
  \ 'fg+':     ['fg', 'Normal'],
  \ 'bg+':     ['bg', 'VertSplit'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'VertSplit'],
  \ 'gutter':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Choosewin settings
let g:choosewin_blink_on_land = 0
let g:choosewin_color_label = { 'gui': [19, 7], 'cterm': [19, 7] }
let g:choosewin_color_label_current = { 'gui': [7, 18], 'cterm': [7, 18] }
let g:choosewin_color_other = { 'gui': [18, 18], 'cterm': [18, 18] }

" Markdown settings
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_no_default_key_mappings = 1
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0

" Fix ctrl-c lag in sql files
let g:ftplugin_sql_omni_key = '<C-j>'

" General settings
set equalalways
set shortmess=aIWtTAcqF
set formatoptions+=n
set formatlistpat=^\\s*\\w\\+[.\)]\\s\\+\\\\|^\\s*[\\-\\+\\*]\\+\\s\\+
set undofile
set undodir=~/.config/nvim/undo/
set laststatus=2
set statusline=\ %f\ %h%w%m%r\ %=%(%l,%c%V\ %=\ %P%)%#VertSplit#x
set textwidth=80
set ignorecase wildignorecase splitright splitbelow
set incsearch nohlsearch
set tabstop=4 shiftwidth=4 expandtab
set nowrap

" Helper functions
fun! g:Cd(dir)
    execute 'cd' a:dir
    call g:DefxStart(0, 1)
    call g:TmuxSetName(g:TmuxGetName())
endfun
fun! g:FzfGenSource(content)
    let cmd = "find $(pwd)"
    if a:content == 'files' || a:content == 'files-content'
        let cmd = cmd . ' -type f'
    elseif a:content == 'directories'
        let cmd = cmd . ' -type d'
    else
        throw 'Invalid argument to FzfGenSource: ' . a:content
    endif
    for i in g:fzf_excludes
        let cmd = cmd . ' -not -path "' . i . '"'
    endfor
    if a:content == 'files-content'
        let cmd = cmd . ' -exec grep -H "" "{}" \;'
    endif
    return cmd
endfun
fun! g:TmuxDetach()
    call system('tmux detach')
endfun
fun! g:TmuxGetName()
    let name = system('tmux list-windows -f "#{window_active}" -F "#{window_name}"')
    return name[1 : stridx(name, ']') - 2]
endfun
fun! g:TmuxNewWin()
    call system('cd && tmux new-window bash -i -c init')
endfun
fun! g:TmuxSelect()
    call fzf#run(fzf#wrap({'source': 'tmux list-windows -F "#{window_index} #{window_name}"', 'sink': funcref('g:FzTmuxChangeWin')}))
endfun
fun! g:TmuxSetName(name)
    call system('tmux rename-window "[' . a:name . '] [' . getcwd() . ']"')
endfun
fun! g:FzTmuxChangeWin(winidx)
    let idx = a:winidx[0 : stridx(a:winidx, ' ') - 1]
    call system('tmux select-window -t ' . idx)
endfun
fun! g:FzFilesEdit(file, fileopentype)
    if a:fileopentype != 'tabedit'
        call choosewin#start(g:DefxOtherWindows(), { 'auto_choose': 1 })
    endif
    execute a:fileopentype a:file
endfun
fun! g:FzFilesEditE(file)
    call g:FzFilesEdit(a:file, 'edit')
endfun
fun! g:FzFilesEditS(file)
    call g:FzFilesEdit(a:file, 'split')
endfun
fun! g:FzFilesEditV(file)
    call g:FzFilesEdit(a:file, 'vsplit')
endfun
fun! g:FzFilesEditT(file)
    call g:FzFilesEdit(a:file, 'tabedit')
endfun
fun! g:FzFileContentsEditE(file)
    call g:FzFilesEdit(a:file[0 : stridx(a:file, ':') - 1], 'edit')
endfun
fun! g:FzFileContentsEditS(file)
    call g:FzFilesEdit(a:file[0 : stridx(a:file, ':') - 1], 'split')
endfun
fun! g:FzFileContentsEditV(file)
    call g:FzFilesEdit(a:file[0 : stridx(a:file, ':') - 1], 'vsplit')
endfun
fun! g:FzFileContentsEditT(file)
    call g:FzFilesEdit(a:file[0 : stridx(a:file, ':') - 1], 'tabedit')
endfun
fun! g:DefxOtherWindows()
    let winnrs = []
    let defxwinnr = bufwinnr('defx')
    for win in getwininfo()
        if win['winnr'] != defxwinnr
            call add(winnrs, win['winnr'])
        endif
    endfor
    return winnrs
endfun
fun! g:DefxChoose(file, diropentype, fileopentype)
    if isdirectory(a:file)
        call defx#call_action('open_tree', a:diropentype)
    else
        let winnrs = g:DefxOtherWindows()
        if len(winnrs) == 0
            execute 'vsplit' a:file
            call g:DefxStart(0, 1)
        else
            call choosewin#start(winnrs, { 'auto_choose': 1 })
        endif
        execute a:fileopentype a:file
    endif
endfun
fun! g:DefxMoveWin(movetype)
    execute 'wincmd' a:movetype
    call g:DefxStart(0, 1)
endfun
fun! g:DefxStart(override, refocus)
    let id = win_getid()
    let defxwinnr = bufwinnr('defx')
    let size = winwidth(defxwinnr)
    let size = size > 0 ? size : 25
    if a:override == 1 || defxwinnr != -1
        Defx -split=vertical -direction=topleft
        wincmd H
        execute 'vertical resize' size
        call defx#call_action('cd', getcwd())
    endif
    if a:refocus == 1
        call win_gotoid(id)
    endif
    wincmd =
endfun
fun! g:StripTrailingWhitespaces()
  if !&binary && &filetype != 'diff'
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
  endif
endfun
command! -bang -complete=dir -nargs=? Cd
    \ call g:Cd(<q-args>)
command! -bang -complete=dir -nargs=? TmuxDetach
    \ call g:TmuxDetach()
command! -bang -complete=dir -nargs=1 TmuxSetName
    \ call g:TmuxSetName(<q-args>)
command! -bang -complete=dir -nargs=? FzFilePathsE
    \ call fzf#run(fzf#wrap({'source': g:FzfGenSource('files'), 'dir': <q-args>, 'sink': funcref('g:FzFilesEditE')}))
command! -bang -complete=dir -nargs=? FzFilePathsS
    \ call fzf#run(fzf#wrap({'source': g:FzfGenSource('files'), 'dir': <q-args>, 'sink': funcref('g:FzFilesEditS')}))
command! -bang -complete=dir -nargs=? FzFilePathsV
    \ call fzf#run(fzf#wrap({'source': g:FzfGenSource('files'), 'dir': <q-args>, 'sink': funcref('g:FzFilesEditV')}))
command! -bang -complete=dir -nargs=? FzFilePathsT
    \ call fzf#run(fzf#wrap({'source': g:FzfGenSource('files'), 'dir': <q-args>, 'sink': funcref('g:FzFilesEditT')}))
command! -bang -complete=dir -nargs=? FzFileContentsE
    \ call fzf#run(fzf#wrap({'source': g:FzfGenSource('files-content'), 'options': '-d: -n2..', 'dir': <q-args>, 'sink': funcref('g:FzFileContentsEditE')}))
command! -bang -complete=dir -nargs=? FzFileContentsS
    \ call fzf#run(fzf#wrap({'source': g:FzfGenSource('files-content'), 'options': '-d: -n2..', 'dir': <q-args>, 'sink': funcref('g:FzFileContentsEditS')}))
command! -bang -complete=dir -nargs=? FzFileContentsV
    \ call fzf#run(fzf#wrap({'source': g:FzfGenSource('files-content'), 'options': '-d: -n2..', 'dir': <q-args>, 'sink': funcref('g:FzFileContentsEditV')}))
command! -bang -complete=dir -nargs=? FzFileContentsT
    \ call fzf#run(fzf#wrap({'source': g:FzfGenSource('files-content'), 'options': '-d: -n2..', 'dir': <q-args>, 'sink': funcref('g:FzFileContentsEditT')}))
command! -bang -complete=dir -nargs=? FzDirectories
    \ call fzf#run(fzf#wrap({'source': g:FzfGenSource('directories'), 'dir': <q-args>, 'sink': funcref('g:Cd')}))

" Set leader
map <space> <leader>

" Defx and Fzf shortcuts
nnoremap <leader>h :term<cr>
nnoremap <leader>s :call g:TmuxSelect()<cr>
nnoremap <leader>S :call g:TmuxNewWin()<cr>
nnoremap <leader>` :call g:Cd('~')<cr>
nnoremap <leader>d :call g:DefxStart(1, 0)<cr>
nnoremap <leader>w :FzDirectories<cr>
nnoremap <leader>fe :FzFilePathsE<cr>
nnoremap <leader>fs :FzFilePathsS<cr>
nnoremap <leader>fv :FzFilePathsV<cr>
nnoremap <leader>ft :FzFilePathsT<cr>
nnoremap <leader>Fe :FzFileContentsE<cr>
nnoremap <leader>Fs :FzFileContentsS<cr>
nnoremap <leader>Fv :FzFileContentsV<cr>
nnoremap <leader>Ft :FzFileContentsT<cr>
fun! g:DefxConfigure() abort
  nnoremap <silent><buffer><nowait> u :call g:Cd('..')<cr>
  nnoremap <silent><buffer><nowait> w :call g:Cd(defx#get_candidate()['action__path'])<cr>
  nnoremap <silent><buffer><nowait> <cr> :call DefxChoose(defx#get_candidate()['action__path'], 'toggle', 'edit')<cr>
  nnoremap <silent><buffer><nowait> o :call g:DefxChoose(defx#get_candidate()['action__path'], 'toggle', 'edit')<cr>
  nnoremap <silent><buffer><nowait> O :call g:DefxChoose(defx#get_candidate()['action__path'], 'recursive', 'edit')<cr>
  nnoremap <silent><buffer><nowait> v :call g:DefxChoose(defx#get_candidate()['action__path'], 'toggle', 'vsplit')<cr>
  nnoremap <silent><buffer><nowait> s :call g:DefxChoose(defx#get_candidate()['action__path'], 'toggle', 'split')<cr>
  nnoremap <silent><buffer><nowait> t :call g:DefxChoose(defx#get_candidate()['action__path'], 'toggle', 'tabedit')<cr>
  nnoremap <silent><buffer><nowait><expr> y defx#do_action('yank_path')
  nnoremap <silent><buffer><nowait><expr> nd defx#do_action('new_directory')
  nnoremap <silent><buffer><nowait><expr> nf defx#do_action('new_file')
  nnoremap <silent><buffer><nowait><expr> d defx#do_action('remove')
  nnoremap <silent><buffer><nowait><expr> r defx#do_action('rename')
  nnoremap <silent><buffer><nowait><expr> <leader>d defx#do_action('cd', getcwd())
endfun

" Tab manipulation
nnoremap ]t :tabnext<cr>
nnoremap [t :tabprevious<cr>
nnoremap ]]t :tabm +1<cr>
nnoremap [[t :tabm -1<cr>
nnoremap <leader>]t :Tabmerge right<cr>
nnoremap <leader>[t :tabprevious<cr>:Tabmerge left<cr>
nnoremap <leader>t <c-w>T
nnoremap <leader>T :tabnew<cr>

" Auto-closers
inoremap " ""<left>
inoremap { {}<left>
inoremap [ []<left>
inoremap ( ()<left>

" General navigation
noremap <m-j> <down>
noremap <m-k> <up>
noremap <m-h> <left>
noremap <m-l> <right>
cnoremap <m-j> <down>
cnoremap <m-k> <up>
cnoremap <m-h> <left>
cnoremap <m-l> <right>
cnoremap <c-d> <right><backspace>
tnoremap <m-j> <down>
tnoremap <m-k> <up>
tnoremap <m-h> <left>
tnoremap <m-l> <right>
inoremap <c-h> <left>
inoremap <c-l> <right>

" Backspace
cnoremap <c-h> <c-w>
tnoremap <c-h> <m-backspace>
inoremap <c-h> <c-w>
inoremap <m-backspace> <backspace>
cnoremap <m-backspace> <backspace>
tnoremap <m-backspace> <backspace>
inoremap <c-d> <right><backspace>

" Terminal navigation
tnoremap <c-w>k <c-\><c-n><c-w>k
tnoremap <c-w>j <c-\><c-n><c-w>j
tnoremap <c-w>h <c-\><c-n><c-w>h
tnoremap <c-w>l <c-\><c-n><c-w>l

" Ponder/markdown shortcuts
nnoremap <leader>n :exec "split " . system("/Users/broma001/projects/ponder/build/bin/ponder -nc default")<cr>
" Choosewin shortcuts
nnoremap - :ChooseWin<cr>
nnoremap _ :ChooseWinSwap<cr>
nnoremap <leader>mc :call jobstart("markdown <c-r>% <bar> textutil -stdin -format html -convert rtf -stdout <bar> pbcopy")<cr>
nnoremap <leader>mC :silent! call jobstart("mkdir -p ~/.tmp/mdpdf && markdown <c-r>% > ~/.tmp/mdpdf/doc.html && wkhtmltopdf --user-style-sheet ~/src/mvp/mvp.css -T 2 -B 0 -L 15 -R 15 ~/.tmp/mdpdf/doc.html ~/.tmp/mdpdf/doc.pdf && echo ~/.tmp/mdpdf/doc.pdf <bar> xclip -sel clipboard")<cr>

" Yank file
nnoremap <leader>Y :let @+ = expand("%:p")<cr>

" System Copy/Paste shortcuts
vnoremap <leader>y "+y
nnoremap <leader>y "+y
nnoremap <leader>yy "+yy
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

" Folds
vnoremap <leader>z <Esc>`<kzfgg`>jzfG`<
nnoremap <leader>Z zE

" Maintain defx buffer on window moves
nnoremap <c-w>H :call g:DefxMoveWin('H')<cr>
nnoremap <c-w>J :call g:DefxMoveWin('J')<cr>
nnoremap <c-w>K :call g:DefxMoveWin('K')<cr>
nnoremap <c-w>L :call g:DefxMoveWin('L')<cr>

" Terminal overrides
augroup myaus
    au!
    au BufRead,BufEnter  * setlocal scrolloff=10 sidescrolloff=10 relativenumber number
    au TermOpen,BufEnter term://* setlocal scrolloff=0 sidescrolloff=0 norelativenumber nonumber
    au BufEnter * setlocal matchpairs=(:),{:},[:]
    au BufEnter term://* setlocal matchpairs=
    au TermOpen * startinsert
    au FileType defx call g:DefxConfigure()
    au BufWritePre,FileWritePre,FileAppendPre,FilterWritePre * call g:StripTrailingWhitespaces()
augroup END

" Colors
syntax on
filetype plugin on
set t_Co=256
set background=dark
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif
fun! s:ColorSchemeOverride() abort
    hi NonText       cterm=NONE ctermfg=0
    hi CursorLine    cterm=NONE ctermbg=18
    hi CursorLineNR  cterm=NONE ctermbg=NONE ctermfg=8
    hi StatusLine    cterm=NONE ctermbg=18
    hi StatusLineNC  cterm=NONE ctermbg=18 ctermfg=8
    hi TabLineSel    cterm=NONE ctermfg=20
    hi Visual        cterm=NONE ctermbg=18
    hi VertSplit     cterm=NONE ctermbg=18 ctermfg=18
    hi LineNR        cterm=NONE ctermbg=NONE ctermfg=19
    hi WildMenu      cterm=NONE ctermbg=15 ctermfg=0
    hi DiffAdd       cterm=bold ctermbg=NONE
    hi DiffDelete    cterm=bold ctermbg=NONE
endfun
augroup OnColorScheme
    au!
    au ColorScheme,BufEnter,BufWinEnter * call s:ColorSchemeOverride()
augroup END
