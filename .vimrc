" pluginless vim config
" for plugins, use neovim

syntax on
set number relativenumber
set autoindent
set smartindent
set shiftwidth=4
set tabstop=4
set mouse=a
set expandtab
set hlsearch
set wildmenu
set background=dark
set clipboard=unnamedplus
set completeopt=menuone,noinsert,noselect,preview

set path+=**

let g:netrw_banner=0
let g:netrw_liststyle=3

" keymaps
nnoremap <tab> :bnext<cr>
nnoremap <s-tab> :bprevious<cr>

nnoremap <a-h> <c-w>h
nnoremap <a-j> <c-w>j
nnoremap <a-k> <c-w>k
nnoremap <a-l> <c-w>l

nnoremap <c-left> <c-w><
nnoremap <c-right> <c-w>>
nnoremap <c-up> <c-w>+
nnoremap <c-down> <c-w>-

nnoremap <leader>bd :bd<cr>
nnoremap <leader>wd <c-w>q

nnoremap <esc> :noh<cr>

" terminal
tnoremap <esc> <c-\><c-n>
nnoremap <buffer> <silent> <leader>b :execute "let @+='b ".expand('%:p').":".getpos('.')[1]."'"<cr>:echo "filename copied: ".@+<cr>
