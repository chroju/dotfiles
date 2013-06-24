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
" NERDTreeToggleをF6に割り当て
nmap <F6> :NERDTreeToggle


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
" todo.txt
NeoBundle 'freitass/todo.txt-vim'
" コメントアウト機能
NeoBundle 'tomtom/tcomment_vim.git'
" 超絶補完
NeoBundle 'Shougo/neocomplcache.vim'
" 括弧の補完
NeoBundle 'tpope/vim-surround'
" メモ？
NeoBundle 'git://github.com/fuenor/qfixhowm.git'
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


"---------------------------
" Key mapping
"---------------------------
" common
nnoremap <C-h> :<C-u>help<Space>
command! Todo edit ~/Dropbox/notes/todo/todo.txt
noremap <Space>l $
noremap <Space>h ^

" 行移動
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" plugins
nnoremap [EverVim] <Nop>
nmap ,e [EverVim]
nnoremap <silent> [EverVim]c :<C-u>EvervimCreate<CR>
nnoremap [NeoBundle] <Nop>
nmap ,n [NeoBundle]
nnoremap <silent> [NeoBundle]i :<C-u>NeoBundleInstall<CR>
" 日付、現在日時の短縮入力
inoremap <Leader>date <C-R>=strftime("%Y-%m-%d")<CR>
inoremap <Leader>now <C-R>=strftime("%Y-%m-%d (%a) %H:%M")<CR>

" easy open .vimrc
let vimrcbody = '$HOME/.vimrc'

function! OpenFile(file)
    let empty_buffer = 
\        line('$') == 1 && strlen(getline('1')) == 0
    if empty_buffer && !&modified
        execute 'e ' . a:file
    else
        execute 'tabnew ' . a:file
    endif
endfunction 

command! OpenMyVimrc call OpenFile(vimrcbody)
nnoremap <Space><Space> :<C-u>OpenMyVimrc<CR>

" easy reload .vimrc
function! SourceIfExists(file)
    if filereadable(expand(a:file))
        execute 'source ' . a:file
    endif
    echo 'Reloaded vimrc.'
endfunction

nnoremap <F5> <Esc>:<C-u>source $MYVIMRC<CR>
\ :source $MYVIMRC<CR>
\ :call SourceIfExists('~/vimfiles/ftplugin/' . &filetype . '.vim')<CR>


"---------------------------
" QFixHowm
"---------------------------

"howm_dirはファイルを保存したいディレクトリを設定。
let howm_dir             = '~/Dropbox/notes/memo'
let howm_filename        = '%Y-%m-%d-%H%M%S.txt'
let howm_fileencoding    = 'utf-8'
let howm_fileformat      = 'unix'
let howm_filetype        = 'markdown'

let QFixHowm_DiaryFile = 'diary/%Y/%m/%Y-%m-%d-000000.howm'
