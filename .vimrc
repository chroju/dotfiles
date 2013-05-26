"---------------------------
"NeoBundle
"---------------------------
if has('vim_starting')
	  set runtimepath+=~/.vim/bundle/neobundle.vim/
	    call neobundle#rc(expand('~/.vim/bundle/'))
endif
" originalrepos on github
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'tomasr/molokai'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'git://github.com/Shougo/unite.vim.git'
NeoBundle 'ujihisa/unite-colorscheme'
NeoBundle 'vim-scripts/Zenburn'
NeoBundle 'nanotech/jellybeans.vim'

"NeoBundle 'https://bitbucket.org/kovisoft/slimv'

filetype indent plugin on     " required!
filetype indent on


""""""""""""""""""""""""""""""
"挿入モード時、ステータスラインの色を変更
""""""""""""""""""""""""""""""
let g:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none'

if has('syntax')
  augroup InsertHook
    autocmd!
    autocmd InsertEnter * call s:StatusLine('Enter')
    autocmd InsertLeave * call s:StatusLine('Leave')
  augroup END
endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
  if a:mode == 'Enter'
    silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
    silent exec g:hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
  endif
endfunction

function! s:GetHighlight(hi)
  redir => hl
  exec 'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction

"---------------------------
"ヴィジュアル
"---------------------------
"set background=dark
colorscheme jellybeans
syntax enable

set t_Co=256

" カーソルライン設定
set cursorline

augroup cch
autocmd! cch
autocmd WinLeave * set nocursorline
autocmd WinEnter,BufRead * set cursorline
augroup END

:hi clear CursorLine
:hi CursorLine gui=underline
highlight CursorLine ctermbg=black guibg=black
" カーソルライン設定ここまで

set nocompatible
set number

set encoding=UTF-8
set fileencoding=UTF-8
set termencoding=UTF-8

set hlsearch

set autoindent
set list
set listchars=tab:^.,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set whichwrap=b,s,h,l,<,>,[,]

"バックアップファイルを作るディレクトリ
set backupdir=$HOME/vimbackup
"クリップボードをWindowsと連携
set clipboard=unnamed
"listで表示される文字のフォーマットを指定する
"set listchars=eol:$,tab:^
"閉じ括弧が入力されたとき、対応する括弧を表示する
set showmatch
"新しい行を作ったときに高度な自動インデントを行う
set smartindent
"行頭の余白内で Tab を打ち込むと、'shiftwidth' の数だけインデントする。
set smarttab
""シフト移動幅
set shiftwidth=4
"ファイル内の <Tab> が対応する空白の数
set tabstop=4

set incsearch "インクリメンタルサーチを行う
set hlsearch "検索結果をハイライトする
set ignorecase "検索時に文字の大小を区別しない
set smartcase "検索時に大文字を含んでいたら大小を区別する
set wrapscan "検索をファイルの先頭へループする

set title "編集中のファイル名を表示する
set showcmd "入力中のコマンドを表示する
set ruler "座標を表示する
set matchtime=3 "showmatchの表示時間
