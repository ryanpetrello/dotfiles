" .vimrc File
" Ryan Petrello
"  
  
"Forget compatibility with Vi. Who cares.  
set nocompatible
set hlsearch
  
"<,Enable filetypes
filetype on
filetype plugin on
filetype indent on
syntax on

" Make sure we use a better leader key
let mapleader = ","
let g:mapleader = ","

" Yanking in vim should also copy into my OSX clipboard
set clipboard=unnamed

" Allow backspacing in insert mode
:set backspace=indent,eol,start

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
set background=dark
colorscheme wombat
  
"Show current command in the screen corner
set showcmd
set history=1000

"Set a page title
set notitle

" Highlight the current line
set cul                                           
hi CursorLine term=none cterm=none ctermbg=3      

" No more bell!
set noerrorbells
set visualbell

" Disable code folding
set nofoldenable

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

" No Help, please
"nmap <F1> <Esc>
  
""""""""""""""""""""""""""""""""""""""""""
" Python-specific
""""""""""""""""""""""""""""""""""""""""""
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" markdown filetype file
au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn}   set filetype=mkd

" For xml, xhtml, html, mak let's use 2 spaces of indentation
autocmd BufNewFile,BufRead *.mako,*.mak setlocal ft=html
autocmd BufNewFile,BufRead *.less setlocal ft=css
autocmd FileType html,xhtml,xml,css setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
 
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,with,try,except,finally,def,class

let g:netrw_list_hide='^\.,.\(pyc\|pyo\|o\)$'

""""""""""""""""""""""""""""""""""""""""""
" Indents, wrapping, line numbers, completion, etc...
""""""""""""""""""""""""""""""""""""""""""

"Show lines numbers  
set relativenumber

"Indent stuff  
set smartindent
set autoindent  
  
"Always show the status line  
set laststatus=2 
set statusline=CWD:%{CurDir()}\ [%{strlen(&fenc)?&fenc:'none'},%{&ff}]\ %h%m%r%y%=%#statuslineerr#%t%*\ %c,%l/%L\ %P\ %#statuslineerr#%{SyntasticStatuslineFlag()}%*
  
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
set mouse=a
  
"Split windows below the current window.  
set splitbelow               
  
" More useful command-line completion  
set wildmenu
set wildmode=list:longest  
  
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" Ack searching and highlight support 
nmap <Leader>a <Esc>:Ack 
let g:ackhighlight = 1

" Hard wrap for the current paragraph
nmap <Leader>w ^mw<C-V>gq`w

" Use chapa.vim default mappings
let g:chapa_default_mappings = 1

" Map <Leader>h to a Mac color picker (hex)
nmap <Leader>h <Esc>:ColorHEX<CR>

" Pytest leader mappings
nmap <silent><Leader>f <Esc>:Pytest file<CR>
nmap <silent><Leader>m <Esc>:Pytest method<CR>
nmap <silent><Leader>c <Esc>:Pytest class<CR>
map <F3> :Pytest session<CR>

" Command to view markdown file you're editing
" (requires http://markedapp.com/)
nnoremap <silent><Leader>M :!open -a Marked.app "%:p"<cr>

"Some functions"
function! CurDir()
    let curdir = substitute(getcwd(), '/Users/ryan', "~", "g")
    return curdir
endfunction

" Create Blank Newlines and stay in Normal mode
nnoremap <silent> zj o<Esc>
nnoremap <silent> zk O<Esc>

" Pasting while in visual mode replaces the selection without overwriting the
" default register
vmap p p :call setreg('"', getreg('0')) <CR>

" syntastic settings
let g:syntastic_enable_signs=1
let g:syntastic_auto_jump=0
let g:syntastic_auto_loc_list=2
let g:syntastic_quiet_warnings=0
let g:syntastic_disabled_filetypes = ['html']

" syntastic autocompletion settings
inoremap <expr> <down> ((pumvisible())?("\<C-n>"):("<down>"))
inoremap <expr> <up> ((pumvisible())?("\<C-p>"):("<up>"))
inoremap <expr> <CR> ((pumvisible())?("\<C-y>"):("<CR>"))
let g:acp_behaviorPythonOmniLength = 5

" Map ,r to reload
command! Reload :so $MYVIMRC
nmap <Leader>r <Esc>:Reload<CR><Esc>:ColorScheme wombat<CR>

" Map ,, to shell out
nmap <Leader>, <Esc>:silent !zsh<CR><CR>:redraw!<CR>

" Auto-alignments for : and = while visually selected
vmap <Leader>a :Align : =<CR>

" Ctrl-p fuzzy search and preferences
nmap <Leader>p <Esc>:CtrlP<CR>
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*.pyc
let g:ctrlp_working_path_mode = 2
let g:ctrlp_open_multi = '1h'
let g:ctrlp_prompt_mappings = {
    \ 'PrtSelectMove("j")':     ['<down>'],
    \ 'PrtSelectMove("k")':     ['<up>'],
    \ 'AcceptSelection("e")':   [],
    \ 'AcceptSelection("h")':   ['<cr>']
    \ }

" Auto-open a split pane with an applicable diff for git commits
autocmd FileType gitcommit DiffGitCached | wincmd L | wincmd p | vertical resize 83
