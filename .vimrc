"---------------------------
" Common
"---------------------------
set number				" 行数表示
set nocompatible		" viとの互換設定を解除
set encoding=UTF-8		" エンコード設定
set fileencoding=UTF-8
set termencoding=UTF-8
"バックアップファイルを作るディレクトリ
set backupdir=$HOME/vimbackup
"クリップボードをOSと連携
set clipboard=unnamed
set title "編集中のファイル名をステータスラインに表示
set showcmd "入力中のコマンドを右下に表示
set ruler "座標を右下に表示
set scrolloff=3 "スクロール時の余白確保
set textwidth=0 "自動折り返しをしない

"---------------------------
" NerdTree
"---------------------------
" 引数なしでvimを開いた場合のみNERDTree起動
let file_name = expand("%")
if has('vim_starting') &&  file_name == ""
    autocmd VimEnter * NERDTree ./
endif

"---------------------------
" NeoBundle
"---------------------------
if has('vim_starting')
	set runtimepath+=~/.vim/bundle/neobundle.vim/
	call neobundle#rc(expand('~/.vim/bundle/'))
endif
" originalrepos on github
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/unite.vim.git'
" カラースキーム
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'tomasr/molokai'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'vim-scripts/Zenburn'
" カラースキームを手軽に変更
NeoBundle 'ujihisa/unite-colorscheme'
" NERDTree
NeoBundle 'scrooloose/nerdtree'
" Markdownプラグイン
NeoBundle 'hallison/vim-markdown'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'tyru/open-browser.vim'
" Evervim
NeoBundle 'kakkyz81/evervim'

"NeoBundle 'https://bitbucket.org/kovisoft/slimv'

filetype indent plugin on     " required!

"---------------------------
" Visual
"---------------------------
"カラースキーム設定
colorscheme jellybeans
syntax enable

" 256色で使用する
set t_Co=256

" カーソルラインのハイライト
set cursorline
" カレントウィンドウのみに罫線を引く
augroup cch
	autocmd! cch
	autocmd WinLeave * set nocursorline
	autocmd WinEnter,BufRead * set cursorline
augroup END
:hi clear CursorLine
:hi CursorLine gui=underline
highlight CursorLine ctermbg=black guibg=black
" カーソルライン設定ここまで

"挿入モード時、ステータスラインの色を変更
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
" ステータスライン設定ここまで

"---------------------------
" Search
"---------------------------
set incsearch "インクリメンタルサーチを行う
set hlsearch "検索結果をハイライトする
set ignorecase "検索時に文字の大小を区別しない
set smartcase "検索時に大文字を含んでいたら大小を区別する
set wrapscan "検索をファイルの先頭へループする
"Escの2回押しでハイライト消去
:nnoremap <ESC><ESC>  :nohlsearch<CR>

"---------------------------
" imput assist
"---------------------------
" オートインデント
set autoindent
" 不可視文字の表示
set list
set listchars=tab:^.,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
" 行頭、行末をすっ飛ばしてカーソル移動
set whichwrap=b,s,h,l,<,>,[,]
"閉じ括弧が入力されたとき、対応する括弧をmatchtime秒表示
set showmatch
set matchtime=3
"新しい行を作ったときに高度な自動インデントを行う
set smartindent
"行頭の余白内で Tab を打ち込むと、'shiftwidth' の数だけインデントする。
set smarttab
set shiftwidth=4
"ファイル内の <Tab> が対応する空白の数
set tabstop=4

"---------------------------
" Complete
"---------------------------
set wildmenu "コマンド補完を強化
set wildmode=list:full " リスト表示，最長マッチ
set history=1000 " コマンド・検索パターンの履歴数
set complete+=k " 補完に辞書ファイル追加

"---------------------------
" Evervim
"---------------------------
let g:evervim_devtoken='S=s19:U=23282c:E=1467e4e8032:C=13f269d5436:P=1cd:A=en-devtoken:V=2:H=3d650edbd18e6d866a60bdc3e9cae317'
