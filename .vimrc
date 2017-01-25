" .vimrc File
" Ryan Petrello
"

""""""""""""""""""""""""""""""""""""""""""
" Pathogen
""""""""""""""""""""""""""""""""""""""""""
call pathogen#infect()

"Forget compatibility with Vi. Who cares.
set nocompatible
set hlsearch

" Enable filetypes
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
" Visual Stuff
""""""""""""""""""""""""""""""""""""""""""
"Display current cursor position in lower right corner.
set ruler

"Hide intro message
set shortmess=filnxtToOI

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

""""""""""""""""""""""""""""""""""
" Forcing myself not to use arrows
""""""""""""""""""""""""""""""""""
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
nmap <F1> <Esc>

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

" For sass, use tabs for indentation (it seems to be prefered method from
" designers I know)
autocmd BufNewFile,BufRead *.scss setlocal ft=scss
autocmd FileType scss setlocal noexpandtab

" Show tabs visually
set list
set list lcs=trail:•,tab:≫ 

autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,with,try,except,finally,def,class

" When editing an email, go to the first line and auto-insert
autocmd BufRead *.mutt/temp/mutt-* execute "normal /^$/\n"
autocmd BufRead *.mutt/temp/mutt-* execute "normal o"
autocmd BufRead *.mutt/temp/mutt-* execute ":startinsert"

" Highlight the word under the cursor so variable names are visible
let s:python_keywords=split(system('python -c "import keyword; print \",\".join(dir(__builtins__) + keyword.kwlist)"'), ',')
function! s:Highlight_Python_Variables()
    let g:word = expand("<cword>")
    if index(s:python_keywords, g:word) < 0
        exe printf('match IncSearch /\<%s\>/', g:word)
    endif
endfunction
autocmd CursorMoved * if &ft ==# 'python' | silent! call s:Highlight_Python_Variables() | endif

let g:netrw_list_hide='^\.,.\(pyc\|pyo\|o\)$'

map <Leader>d :call InsertLine()<CR>

function! InsertLine()
  let trace = expand("import pdb; pdb.set_trace()")
  execute "normal o".trace
endfunction

""""""""""""""""""""""""""""""""""""""""""
" Perl-specific
""""""""""""""""""""""""""""""""""""""""""
autocmd FileType perl setlocal tabstop=4 shiftwidth=4 noexpandtab

""""""""""""""""""""""""""""""""""""""""""
" Indents, wrapping, line numbers, completion, etc...
""""""""""""""""""""""""""""""""""""""""""

"Show lines numbers
set relativenumber

"Indent stuff
set smartindent
set autoindent
inoremap # X<BS>#

"Always show the status line
set laststatus=2

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

" Create Blank Newlines and stay in Normal mode
nnoremap <silent> zj o<Esc>
nnoremap <silent> zk O<Esc>

" Pasting while in visual mode replaces the selection without overwriting the
" default register
vmap p p :call setreg('"', getreg('0')) <CR>

" Goto last location in non-empty files
autocmd BufReadPost *  if line("'\"") > 1 && line("'\"") <= line("$")
                   \|     exe "normal! g`\""
                   \|  endif

" Square up visual selections
set virtualedit=block

" $Show the column marker in visual insert mode

vnoremap <silent>  I  I<C-R>=TemporaryColumnMarkerOn()<CR>
vnoremap <silent>  A  A<C-R>=TemporaryColumnMarkerOn()<CR>

function! TemporaryColumnMarkerOn ()
    set cursorcolumn
    inoremap <silent>  <ESC>  <ESC>:call TemporaryColumnMarkerOff()<CR>
    return ""
endfunction

function! TemporaryColumnMarkerOff ()
    set nocursorcolumn
    iunmap <ESC>
endfunction

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

" Map ,s to split all open buffer windows.  Can be used to toggle horizontal/vertical
nmap <Leader>s <Esc>:call ToggleBuff()<CR>
let g:vertical_buff = 1
function! ToggleBuff()
    if( g:vertical_buff == 0 )
        exec ":sun"
        let g:vertical_buff = 1
    else
        exec ":vertical sun"
        let g:vertical_buff = 0
    endif
endfunction

" enable fzf completion
set rtp+=/usr/local/opt/fzf
nmap <Leader>p <Esc>:FZF<CR>
let g:fzf_action = {
  \ 'enter': 'split' }
let g:fzf_layout = { 'down': '20%' }

" Auto-open a split pane with an applicable diff for git commits
autocmd FileType gitcommit DiffGitCached | wincmd L | wincmd p | vertical resize 83 | DimInactiveOff

" Change cursor shape between insert and normal mode in iTerm2.app
if $TERM_PROGRAM =~ "iTerm"
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\" " Vertical bar in insert mode
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\" " Block in normal mode
endif

" Mute colors for inactive tmux panes
au FocusLost * :silent! set t_Co=0
au FocusGained * :silent! set t_Co=256
au FocusGained * :silent! ColorScheme wombat<Cr>
let g:vitality_always_assume_iterm = 1

" Disable syntax highlight on inactive vim windows
let g:diminactive_use_syntax = 1
