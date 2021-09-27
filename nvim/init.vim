" PLUGINS
call plug#begin()
Plug 'chriskempson/base16-vim'
Plug 'leafgarland/typescript-vim'
Plug 'godlygeek/tabular'
Plug 'pangloss/vim-javascript'
Plug 'scrooloose/nerdtree'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
call plug#end()

" NERDTree settings
let g:NERDTreeMinimalUI=1
let g:NERDTreeCascadeSingleChildDir=1
let g:NERDTreeCascadeOpenSingleChildDir=1

" CtrlP settings
let g:ctrlp_max_files = 100
let g:ctrlp_user_command = [
    \ '.git', 'cd %s && git ls-files . -co --exclude-standard',
    \ 'find %s -type f'
    \ ]

" Colors
syntax on
filetype plugin on
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif
hi NonText       cterm=NONE ctermfg=0
hi CursorLine    cterm=NONE ctermbg=18
hi CursorLineNR  cterm=NONE ctermbg=NONE ctermfg=8
hi StatusLine    cterm=NONE ctermbg=18 ctermfg=32
hi StatusLineNC  cterm=NONE ctermbg=18 ctermfg=19
hi Visual        cterm=NONE ctermbg=17
hi VertSplit     cterm=NONE ctermbg=18 ctermfg=18
hi LineNR        cterm=NONE ctermbg=NONE ctermfg=19

" General settings
set undofile                          " Persistent undo
set undodir=~/.config/nvim/undo/      " Undo directory
setglobal number relativenumber       " Line numbers
setglobal scrolloff=10                " Keep 10 lines above/below cursor
set laststatus=2                      " Always display the status line
set nowrap                            " Don't wrap text
set tabstop=4 shiftwidth=4 expandtab  " Tabs are 4 spaces
set nohlsearch                        " Don't keep search results highlighted
set ignorecase                        " Search is case insensitive
set wildignorecase                    " Tab-completion is case insensitive
let g:ftplugin_sql_omni_key = '<C-j>' " Fix ctrl-c lag in sql files

" NERDTree and CtrlP shortcuts
map <space> <leader>
nnoremap <leader>d :NERDTree<cr>
nnoremap <leader>f :CtrlP<cr>

" System copy/paste shortcuts
vnoremap <leader>y "+y
nnoremap <leader>Y "+yg_
nnoremap <leader>y "+y
nnoremap <leader>yy "+yy
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

" Auto enter insert mode in terminal
autocmd BufWinEnter,WinEnter term://* startinsert
autocmd BufLeave term://* stopinsert

" Disable scrolloff and numbering in terminals
autocmd BufRead * setlocal scrolloff=10
autocmd TermOpen,BufEnter term://* setlocal scrolloff=0 norelativenumber nonumber

" Enable esc and ctrl-w hjkl in terminals
tnoremap <esc> <C-\><C-n>
tnoremap <C-w>h <C-\><C-n><C-w>h
tnoremap <C-w>j <C-\><C-n><C-w>j
tnoremap <C-w>k <C-\><C-n><C-w>k
tnoremap <C-w>l <C-\><C-n><C-w>l

" Auto closers
inoremap ( ()<left>
inoremap { {}<left>
inoremap [ []<left>
inoremap (<space> (  )<left><left>
inoremap {<space> {  }<left><left>
inoremap [<space> [  ]<left><left>
inoremap " ""<left>
inoremap <c-h> <left>
inoremap <c-l> <right>

" Fold everything but selection
vnoremap <leader>z <Esc>zE`<kzfgg`>jzfG`<

" Delete all folds
nnoremap <leader>Z zE

" Search git files for strings
nnoremap <leader>w :silent argadd <c-r>%<cr> :silent argdelete *<cr> :silent argadd `git ls-files`<cr> :vimgrep /<c-r><c-w>/ ##<cr>
nnoremap <leader>s :silent argadd <c-r>%<cr> :silent argdelete *<cr> :silent argadd `git ls-files`<cr> :vimgrep // ##<left><left><left><left>

" Cycle quickfix list
nnoremap ]c :cnext<cr>
nnoremap [c :cprev<cr>

" Cycle tabs
nnoremap ]t :tabnext<cr>
nnoremap [t :tabprev<cr>

" Create tabs tabs
nnoremap <leader>t <c-w>T
nnoremap <leader>T :tabnew<cr>

" List buffers
nnoremap <leader>l :ls<cr>:b<space>

" Trim trailing whitespace on save
fun! <SID>StripSpace()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
" autocmd BufWritePre * :call <SID>StripSpace()

" Show syntax group under cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
  \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
  \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Delete hidden buffers
fun! DeleteHiddenBuffers()
    let tpbl=[]
    call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
    for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
        silent execute 'bwipeout' buf
    endfor
endfunction

" Fix broken cursorline in nerdtree with neovim
function! s:CustomizeColors()
	if has('guirunning') || has('termguicolors')
		let cursorline_gui=''
		let cursorline_cterm='ctermfg=white'
	else
		let cursorline_gui='guifg=white'
		let cursorline_cterm=''
	endif
	exec 'hi CursorLine ' . cursorline_gui . ' ' . cursorline_cterm
endfunction
augroup OnColorScheme
	autocmd!
	autocmd ColorScheme,BufEnter,BufWinEnter * call s:CustomizeColors()
augroup END
