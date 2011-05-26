" .vimrc File  
" Ryan Petrello
"  
  
"Forget compatibility with Vi. Who cares.  
set nocompatible
set hlsearch
  
"Enable filetypes
filetype on
filetype plugin on
filetype indent on
syntax on

" Make sure we use a better leader key
let mapleader = ","
let g:mapleader = ","

" Yanking in vim should also copy into my OSX clipboard
set clipboard=unnamed

""""""""""""""""""""""""""""""""""""""""""
" Pathogen
""""""""""""""""""""""""""""""""""""""""""
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

""""""""""""""""""""""""""""""""""""""""""
" Visual Stuff
""""""""""""""""""""""""""""""""""""""""""
"Display current cursor position in lower right corner.  
set ruler
  
"Set the color scheme. Change this to your preference.  
"Here's 100 to choose from: http://www.vim.org/scripts/script.php?script_id=625
colorscheme wombat
set t_Co=256
set background=dark
  
"Set font type and size. Depends on the resolution. Larger screens, prefer h20  
set guifont=Inconsolata:h14

"Show current command in the screen corner
set showcmd
set history=1000

"Set a page title
set title

" Highlight the current line
set cul                                           
hi CursorLine term=none cterm=none ctermbg=3      

" No more bell!
set noerrorbells
set visualbell


""""""""""""""""""""""""""""""""""""""""""
" Custom Commands
""""""""""""""""""""""""""""""""""""""""""
command Ga call Ga()
command Gc exe 'Git commit' 
command Gp exe 'Git push'


""""""""""""""""""""""""""""""""""""""""""
" Forcing myself not to use arrows 
""""""""""""""""""""""""""""""""""""""""""
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk
  
""""""""""""""""""""""""""""""""""""""""""
" Python-specific
""""""""""""""""""""""""""""""""""""""""""
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" For xml, xhtml, html, mak let's use 2 spaces of indentation
autocmd BufNewFile,BufRead *.mako,*.mak setlocal ft=html
autocmd BufNewFile,BufRead *.less setlocal ft=css
autocmd FileType html,xhtml,xml,css setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
 
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,with,try,except,finally,def,class

let g:netrw_list_hide='^\.,.\(pyc\|pyo\|o\)$'

""""""""""""""""""""""""""""""""""""""""""
" Indents, wrapping, line numbers, completion, etc...
""""""""""""""""""""""""""""""""""""""""""

if has("gui_running")
    "Show lines numbers  
    set relativenumber

    "Hide the toolbar
    set guioptions=egmrt
endif

"Indent stuff  
set smartindent
set autoindent  
  
"Always show the status line  
set laststatus=2 
set statusline=%F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c
  
"Prefer a slightly higher line height  
set linespace=3  
  
"Better line wrapping  
set wrap  
set textwidth=79  
set colorcolumn=+1
set formatoptions=qrn1  

""""""""""""""""""""""""""""""""""""""""""
" Other Functionality
""""""""""""""""""""""""""""""""""""""""""

" Keep more context when scrolling off the end of a buffer
set scrolloff=3
  
"Set incremental searching"  
set incsearch  
  
" case insensitive search  
set ignorecase  
set smartcase
  
"Hide mouse when typing  
set mousehide  
  
"Split windows below the current window.  
set splitbelow               
  
" More useful command-line completion  
set wildmenu
set wildmode=list:longest  
  
"http://vim.wikia.com/wiki/Make_Vim_completion_popup_menu_work_just_like_in_an_IDE  
set completeopt=longest,menuone  
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"  
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :  
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'  
inoremap <expr> <M-,> pumvisible() ? '<C-n>' :  
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'  
  
"Map escape key to jj -- much faster  
imap jj <esc>

set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" Toggle NERDTREE with F2"
map <F2> :NERDTreeToggle<CR>

" Ack searching and highlight support 
nmap <Leader>a <Esc>:Ack 
let g:ackhighlight = 1

" Hard wrap for the current paragraph
nmap <Leader>w ^mw<C-V>gq`w

" Use chapa.vim default mappings
let g:chapa_default_mappings = 1

" Map <Leader>h to a Mac color picker (hex)
nmap <Leader>h <Esc>:ColorHEX<CR>

" Pyflakes config
let g:pyflakes_use_quickfix = 0

" Pytest leader mappings
nmap <silent><Leader>f <Esc>:Pytest file<CR>
nmap <silent><Leader>m <Esc>:Pytest method<CR>
nmap <silent><Leader>c <Esc>:Pytest class<CR>
map <F3> :Pytest session<CR>

"Some functions"
function! CurDir()
    let curdir = substitute(getcwd(), '/Users/ryan', "~", "g")
    return curdir
endfunction

" Git commit add single file please 
function! Ga()
    let cwd = expand("%:p")
    exe 'Git add ' . cwd
endfunction

" Create Blank Newlines and stay in Normal mode
nnoremap <silent> zj o<Esc>
nnoremap <silent> zk O<Esc>
