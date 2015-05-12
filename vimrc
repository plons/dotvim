" don't be vi-compatible
set nocompatible

" change leader (default is ',')
let mapleader=" "

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" git-driven install of plugins and auto integration
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if filereadable(expand("$HOME/.vim/autoload/pathogen.vim"))
   silent! call pathogen#infect()
endif

if has("autocmd")
   " clear any existing autocmd
   autocmd!

   " auto insertion of comment leaders
   autocmd FileType c,cpp set formatoptions+=ro

   " left aligned c,cpp comment starting with /**, middle **, ending with **/
   autocmd FileType c,cpp set comments-=s1:/*,mb:*,ex:*/
   autocmd FileType c,cpp set comments+=s1:/*!,mb:**,ex:*/,sr:/**,mb:**,ex:*/ 

   " autocompletion
   autocmd FileType c,cpp iab /*** /******************************************************************************

   autocmd FileType c,cpp,h,hpp setlocal ts=4 sts=4 sw=4 noexpandtab

   autocmd FileType xml setlocal ts=3 sts=3 sw=3 expandtab

   " Treat .ssl files as XML
   autocmd BufNewFile,BufRead *.ssl,*.rss setfiletype xml
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-airline
""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set statusline+=%F
set laststatus=2
let g:airline#extensions#tabline#enabled = 1
nmap <C-b> :bn<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" color scheme
" More info at https://github.com/altercation/vim-colors-solarized
" ==> REQUIRES https://github.com/Anthony25/gnome-terminal-colors-solarized
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if ! has("gui_running")
   set t_Co=256
endif
"set background=dark
set background=light
colorscheme solarized


"""""""""""""""""""""""""""""""""""""""
" terminal settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" syntax highlighting
if has('syntax') && (&t_Co > 1)
   syntax enable
endif

" history buffer
set history=50

" rehighlight off
"set viminfo='10,f1,<500,h

" displays in status line
set showmode
set showcmd

" don't have files override this .vimrc
set nomodeline

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" filetype detection
filetype plugin indent on


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" text formatting
"
" syntax highlighting

syntax on

set hlsearch

" <Ctrl-l> redraws the screen and removes any search highlighting.
" nnoremap <CR> :noh<CR> ===> DO NOT USE THIS MAPPING: will cause problems with other uses of CR (e.g. in YcmDiags)
nnoremap <silent> <C-l> :set nolist<CR>:nohl<CR><C-l>

" Shortcut to rapidly toggle `set list`
" nmap <leader>l :set list!<CR> ===> DO NOT USE THIS MAPPING: will cause problems in combination with easymotion
" set list

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

" wrapping
set nowrap
set formatoptions-=t " no auto-wrap, except for comments
set textwidth=128

" line numbers
set number
set nuw=6

" indents
set shiftwidth=3
set expandtab
set autoindent


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" help

" goto next help bookmark in the current buffer
nmap <s-b> /<bar>:\?\(\S\+-\?\)\+<bar><cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace visual selection using ctrl+r
" Escape special characters in a string for exact matching.
" This is useful to copying strings from the file to the search tool
" Based on this - http://peterodding.com/code/vim/profile/autoload/xolox/escape.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! EscapeString (string)
   let string=a:string
   " Escape regex characters
   let string = escape(string, '^$.*\/~[]')
   " Escape the line endings
   let string = substitute(string, '\n', '\\n', 'g')
   return string
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Get the current visual block for search and replaces
" This function passed the visual block through a string escape function
" Based on this - http://stackoverflow.com/questions/676600/vim-replace-selected-text/677918#677918
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetVisual() range
   " Save the current register and clipboard
   let reg_save = getreg('"')
   let regtype_save = getregtype('"')
   let cb_save = &clipboard
   set clipboard&

   " Put the current visual selection in the " register
   normal! ""gvy
   let selection = getreg('"')

   " Put the saved registers and clipboards back
   call setreg('"', reg_save, regtype_save)
   let &clipboard = cb_save

   "Escape any special characters in the selection
   let escaped_selection = EscapeString(selection)

   return escaped_selection
endfunction

" Start the find and replace command across the entire file
"vmap <leader>z <Esc>:%s/<c-r>=GetVisual()<cr>/
"vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>
vnoremap <C-r> <Esc>:%s/<c-r>=GetVisual()<cr>//gc<left><left><left>

" Find resource using CtrlP plugin with the same shortcut as eclipse
" noremap <C-R> :CtrlP<CR> ===> DO NOT USE THIS MAPPING: <C-r> is already used for 'redo' command
noremap <C-o> :TagbarToggle<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" resize split windows
""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <s-h> <c-w><
nmap <s-j> <c-w>-
nmap <s-k> <c-w>+
nmap <s-l> <c-w>>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" moving between tabs (you can also use gt and gT)
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ===> DO NOT USE THIS MAPPING
" <C-l> is already in use for clearing the screen
" map  <C-l> :tabnext<CR>
" map  <C-h> :tabprevious<CR>
" map  <C-n> :tabnew<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" inserting newline
""""""""""""""""""""""""""""""""""""""""""""""""""""""
"nmap <S-Enter> O<Esc>j
"===> DO NOT USE THIS MAPPING
"Using the mapping would disable enter to be used in the command or search window!
"nmap <CR> o<Esc>k

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let NERDTreeDirArrows=0
let NERDTreeIgnore=['\.swp$', '^\.git', '\~$']
nmap <s-q> :NERDTreeFind<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDCommenter
""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <C-c> <leader>c<space>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" taglist: http://sourceforge.net/projects/vim-taglist
"""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <s-w> :TlistToggle<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" easymotion
""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)

let g:EasyMotion_startofline = 0 " keep cursor colum when JK motion

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" conque term
" let g:ConqueTerm_ReadUnfocused = 1
" nmap <s-a> :ConqueTermSplit bash<cr>


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set tabstop, softtabstop and shiftwidth to the same value
""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -nargs=* Stab call Stab()
function! Stab()
   let l:tabstop = 1 * input('set tabstop = softtabstop = shiftwidth = ')
   if l:tabstop > 0
      let &l:sts = l:tabstop
      let &l:ts = l:tabstop
      let &l:sw = l:tabstop
   endif
   call SummarizeTabs()
endfunction

function! SummarizeTabs()
   try
      echohl ModeMsg
      echon 'tabstop='.&l:ts
      echon ' shiftwidth='.&l:sw
      echon ' softtabstop='.&l:sts
      if &l:et
         echon ' expandtab'
      else
         echon ' noexpandtab'
      endif
   finally
      echohl None
   endtry
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" YouCompleteMe
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ycm_confirm_extra_conf = 0

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Preserve last search and cursor position
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! Preserve(command)
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    execute a:command
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction 

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cleanup whitespace at the end of a line
""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap _$ :call Preserve("%s/\\s\\+$//e")<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Unite
" :help unite
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:unite_source_history_yank_enable = 1
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
nnoremap <C-h> :Unite history/yank<cr>
"nnoremap <C-p> :Unite file_rec/async<cr>
nnoremap <C-g> :Unite grep:.<cr>
nnoremap <C-f> :Unite -start-insert file_rec/async<cr>

nnoremap <silent> ,g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
if executable('ag')
   let g:unite_source_grep_command='ag'
   let g:unite_source_grep_default_opts='--nocolor --line-numbers --nogroup -S -C4'
   let g:unite_source_grep_recursive_opt=''
elseif executable('pt')
   let g:unite_source_grep_command = 'pt'
   let g:unite_source_grep_default_opts = '--nogroup --nocolor'
   let g:unite_source_grep_recursive_opt = ''
   let g:unite_source_grep_encoding = 'utf-8'
endif
