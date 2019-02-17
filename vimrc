let mapleader=","

" Set ,g as a shortcut for turning spell checking on and off.
nmap <silent> <leader>s :set spell!<CR>

" Add some shortcuts for opening files in other directories.
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>e :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%

" Required setup for Vundle
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
" Add nerdtree
"Plugin 'scrooloose/nerdtree'
" Add control-P fuzzy file finder
Plugin 'ctrlpvim/ctrlp.vim'
" Add the fugitive Git plugin
Plugin 'tpope/vim-fugitive'
" GutenTags automatically generates/regenerates ctags and uses the ctags file
" to improve autocompletion results.
Plugin 'ludovicchabant/vim-gutentags'
" Use syntastic for syntax checking. YouCompleteMe would be better, but its
" harder to configure. Try jedi as a better option for Python.
Plugin 'scrooloose/syntastic'
let g:syntastic_cpp_checkers = ['gcc']
let g:syntastic_cpp_compiler = 'gcc'
let g:syntastic_cpp_compiler_options = '-std=c++14'

" Quickly exchange text using the 'cx' command
Plugin 'tommcdo/vim-exchange'

" Plugins for automatically closing parenthesis, quotes, etc...
"
" Delimit automatically closes parenthesis, quotes, etc...
" Plugin 'Raimondi/delimitMate'
" Plugin 'jiangmiao/auto-pairs'

" Plugins for marking indentation
"
" Put colored bars in to highlight indenting
" Plugin 'nathanaelkane/vim-indent-guides'
" Put a line on indent columns.
"Plugin 'Yggdroot/indentLine'

" Many options for auto-completion
"
" Add YouCompleMe auto-completion and syntax checking
" Plugin 'Valloric/YouCompleteMe'
" Use neocomplete instead of YouCompleteMe. YCM looks awesome and has more
" features, but the configuration is too difficult for me.
"Plugin 'Shougo/neocomplete.vim'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Handle automatic indention of code using spaces instead of tabs
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab
set softtabstop=4
set autoindent  " always set autoindenting on

if has("vms")
  set nobackup  " do not keep a backup file, use versions instead
else
  set backup    " keep a backup file
endif
set history=50  " keep 50 lines of command line history
set ruler       " show the cursor position all the time
set showcmd     " display incomplete commands
set incsearch   " do incremental searching
set number      " display line numbers
set wrap        " Turn on line wrapping
set linebreak   " Make line wrapping occur on work boundaries.
"set fo=ta       " Set vim to wrap lines automatically as you type
set tags=tags;/         " Look for tag files from current directory to root.

" Ignore whitespace when running a diff
if &diff
    set diffopt +=iwhite
endif

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvs<C-R>=current_reg<CR><Esc>

" scroll the viewport faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
 filetype plugin indent on

  " Open the Nerdtree file browser and switch to the file window
  " autocmd VimEnter * NERDTree | wincmd p

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " Don't expand tabs in Makefiles
  autocmd FileType make setlocal noexpandtab

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set WiX include (*.wxi) files as XML
  autocmd BufNewFile,BufReadPost *.wxi set filetype=xml

  " Use clang-format for indenting C and C++ files.
  autocmd FileType c,cpp setlocal equalprg=clang-format

  " Use tidy to format XML and HTML files.
  autocmd FileType xml setlocal equalprg=tidy\ --indent-spaces\ 4\ --indent-attributes\ yes\ --sort-attributes\ alpha\ --drop-empty-paras\ no\ --vertical-space\ yes\ --wrap\ 80\ -i\ -xml\ 2>/dev/null

endif " has("autocmd")

source $VIMRUNTIME/colors/elflord.vim
" source $VIMRUNTIME/browser.vim
behave mswin

" vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
  au BufReadPre  *.dat let &bin=1
  au BufReadPost *.dat if &bin | %!xxd
  au BufReadPost *.dat set ft=xxd | endif
  au BufWritePre *.dat if &bin | %!xxd -r
  au BufWritePre *.dat endif
  au BufWritePost *.dat if &bin | %!xxd
  au BufWritePost *.dat set nomod | endif
augroup END

" Show trailing whitespace and tabs
set list listchars=tab:\|_,trail:.
highlight SpecialKey ctermfg=DarkGray

" Remove trailing whitespace when saving files.
autocmd FileType c,cpp,python,ruby,java autocmd BufWritePre <buffer> :%s/\s\+$//e

" Add a hook for select all
map <C-a> <esc>ggVG<CR>

" Mappings for control-P fuzzy file finder.
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
" Search the current directory or the nearest ancestor directory with a .git
" directory.
let g:ctrlp_working_path_mode = 'ra'

" Mappings for the fugitive Git wrapper plugin
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
nmap <leader>gst :Gstatus<cr>
nmap <leader>gci :Gcommit<cr>
nmap <leader>gadd :Gwrite<cr>
nmap <leader>gd :Gdiff<cr>

" Options for delimit to add space between {} by using control-C
inoremap <C-c> <CR><Esc>O

" Options for auto-pair
let g:AutoPairsMultilineClose = 0

" Options for Syntastic.
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Set the netrw file browser options
let g:netrw_liststyle=0
let g:netrw_banner=0

" Highlight a boundary at 80 characters.
":highlight ColorColumn ctermbg=Gray guibg=Gray
":set colorcolumn=80
