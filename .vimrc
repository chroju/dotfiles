"---------------------------
" Common
"---------------------------
set number							" 行数表示
set notitle							" 変なタイトル表示しない
set nocompatible				" viとの互換設定を解除
set nobackup						" バックアップファイルを作成しない
set noswapfile					" スワップファイルを作成しない
set hidden							" 未保存バッファがあっても無視する
set clipboard+=unnamed	" クリップボードをOSと連携
set showcmd							" 入力中のコマンドを右下に表示
set ruler								" 座標を右下に表示
set scrolloff=3					" スクロール時の余白確保
set textwidth=0					" 自動折り返しをしない
set noerrorbells				" エラー時にビープ音を鳴らさない
set vb t_vb=  					" ビープ音をビジュアルベル（空文字）に置き換え
set ambiwidth=double		" マルチバイト文字のズレを防ぐ
" デフォルト設定のtxtファイルのtextwidthを上書き
autocmd FileType text setlocal textwidth=0

" set augroup
augroup MyAutoCmd
  autocmd!
augroup END


"---------------------------
" encoding
"---------------------------
" 内部文字コード設定
set encoding=UTF-8
" 保存ファイルエンコード設定
set fileencoding=UTF-8
" ファイルの文字コード自動判別設定
set fileencodings=ucs-bom,iso-2022-jp,cp932,sjis,euc-jp,UTF-8
" 改行コード設定
set fileformat=unix
set fileformats=unix,dos,mac


"---------------------------
" NeoBundle
"---------------------------
filetype off

if has('vim_starting')
	set runtimepath+=~/.vim/bundle/neobundle.vim/
	call neobundle#rc(expand('~/.vim/bundle/'))
endif
" originalrepos on github
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc', {
      \ 'build' : {
      \     'windows' : 'tools\\update-dll-mingw',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }
" colorscheme
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'tomasr/molokai'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'vim-scripts/Zenburn'
NeoBundle 'w0ng/vim-hybrid'
NeoBundle 'vim-scripts/twilight'
NeoBundle 'cocopon/iceberg.vim'
" Unite
NeoBundle 'Shougo/unite.vim.git'
" NeoBundle 'Shougo/unite-outline'
" カラースキームを手軽に変更
NeoBundle 'ujihisa/unite-colorscheme'
" NERDTree
NeoBundle 'scrooloose/nerdtree'
" Markdownプラグイン
NeoBundle 'rcmdnk/vim-markdown'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'tyru/open-browser.vim'
" Evervim
NeoBundle 'kakkyz81/evervim'
" todo.txt
NeoBundle 'freitass/todo.txt-vim'
" コメントアウト機能
NeoBundle 'tomtom/tcomment_vim.git'
" 超絶補完
NeoBundle 'Shougo/neocomplete.vim'
" 括弧の操作補完
NeoBundle 'tpope/vim-surround'
" howm
NeoBundle 'fuenor/qfixhowm.git'
" vim hacksをvimで読む
NeoBundle 'choplin/unite-vim_hacks'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'mattn/wwwrenderer-vim'
NeoBundle 'thinca/vim-openbuf'
" Google Tasks
NeoBundle 'mattn/googletasks-vim'
"NeoBundle 'https://bitbucket.org/kovisoft/slimv'
" emmet
NeoBundle 'mattn/emmet-vim'
" Ruby & Rails
NeoBundle 'tpope/vim-rails'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'honza/vim-snippets'
NeoBundle 'vim-scripts/dbext.vim'
NeoBundle 'AndrewRadev/switch.vim'
" text edit support
NeoBundle 'vim-scripts/Align'
NeoBundle 'vim-scripts/YankRing.vim'
NeoBundle 'vim-scripts/Changed'
" ステータスライン
NeoBundle 'itchyny/lightline.vim'
" LESSハイライト
NeoBundle 'groenewege/vim-less'
" Gist
NeoBundle 'mattn/Gist-vim'
" 爆速カーソル移動
NeoBundle 'Lokaltog/vim-easymotion'

filetype indent plugin on     " required!


"---------------------------
" Visual
"---------------------------
"カラースキーム設定
colorscheme iceberg
syntax enable

" 256色で使用する
set t_Co=256

" カーソルラインのハイライト
set cursorline
" カレントウィンドウのみに罫線を引く
augroup cch
	autocmd!
	autocmd WinLeave * set nocursorline
	autocmd WinEnter,BufRead * set cursorline
augroup END
hi clear CursorLine
hi CursorLine ctermbg=black guibg=black
" カーソルライン設定ここまで


"---------------------------
" Search
"---------------------------
set incsearch	"インクリメンタルサーチを行う
set hlsearch	"検索結果をハイライトする
set ignorecase	"検索時に文字の大小を区別しない
set smartcase	"検索時に大文字を含んでいたら大小を区別する
set wrapscan	"検索をファイルの先頭へループする

"Escの2回押しでハイライト消去
nnoremap <ESC><ESC>  :nohlsearch<CR>


"---------------------------
" input assist
"---------------------------
" オートインデント
set autoindent
" 不可視文字の表示
set list
set listchars=tab:^.,trail:-,eol:$
" 行頭、行末をすっ飛ばしてカーソル移動
set whichwrap=b,s,h,l,<,>,[,]
"閉じ括弧が入力されたとき、対応する括弧をmatchtime秒表示
set showmatch
set matchtime=3
"新しい行を作ったときに高度な自動インデントを行う
set smartindent
"行頭の余白内で Tab を打ち込むと、'shiftwidth' の数だけインデントする。
set expandtab
set shiftwidth=2
"ファイル内の <Tab> が対応する空白の数
set tabstop=2
" 括弧の補完
inoremap () ()<Left>
inoremap "" ""<Left>
inoremap [] []<Left>
inoremap {} {}<Left>
inoremap '' ''<Left>
inoremap <> <><Left>
inoremap ** **<Left>


"---------------------------
" Complete
"---------------------------
set wildmenu "コマンド補完を強化
set wildmode=list:full " リスト表示，最長マッチ
set history=1000 " コマンド・検索パターンの履歴数
set complete+=k " 補完に辞書ファイル追加


"---------------------------
" Tab
"---------------------------
nnoremap [Tab] <Nop>
nnoremap ,t [Tab] " Tab jump
for n in range(1, 9)
	execute 'nnoremap <silent> [Tab]'.n ':<C-u>tabnext'.n.'<CR>'
endfor
" t1 で1番左のタブ、t2 で1番左から2番目のタブにジャンプ

map <silent> [Tab]c :tablast <bar> tabnew<CR> " tc 新しいタブを一番右に作る
map <silent> [Tab]x :tabclose<CR> " tx タブを閉じる
map <silent> [Tab]n :tabnext<CR> " tn 次のタブ
map <silent> [Tab]p :tabprevious<CR> " tp 前のタブ


"---------------------------
" Key mapping
"---------------------------
" common
nnoremap ,, :up<CR>
nnoremap <C-h> :<C-u>help<Space>
noremap <Space>l $
noremap <Space>h ^

" タブ操作
nnoremap tc :<C-u>tabnew<CR>
nnoremap tx :<C-u>tabclose<CR>

" 行移動
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
vnoremap j gj
vnoremap k gk
vnoremap gj j
vnoremap gk k

" 入力効率化
onoremap ) t)
onoremap ( t(
vnoremap ) t)
vnoremap ( t(

" buffer
nnoremap bb :ls<CR>:buf

" 編集中のファイルのディレクトリに移動
nnoremap ,d :execute ":lcd" . expand("%:p:h")<CR>

" GTD
nnoremap [GTD] <Nop>
nmap ,g [GTD]
nnoremap <silent> [GTD]l :<C-u>tabnew<Space>~/Dropbox/todo.txt<CR>
nnoremap <silent> [GTD]g :<C-u>tabnew<Space>~/Dropbox/notes/gtd/gtd.txt<CR>
nnoremap <silent> [GTD]t :<C-u>tabnew<Space>~/Dropbox/notes/gtd/トリガーリスト.txt<CR>
nnoremap <silent> [GTD]r :<C-u>tabnew<Space>~/Dropbox/notes/gtd/ルーチンタスクリスト.txt<CR>

" plugins
" NERDTreeToggleをF6に割り当て
nmap <F6> :NERDTreeToggle<CR>
" EverVim
nnoremap [EverVim] <Nop>
nmap ,e [EverVim]
nnoremap <silent> [EverVim]c :<C-u>EvervimCreate<CR>
nnoremap <silent> [EverVim]n :<C-u>EvervimNotebookList<CR>
nnoremap <silent> [EverVim]t :<C-u>EvervimListTags<CR>
" NeoBundle
nnoremap [NeoBundle] <Nop>
nmap ,n [NeoBundle]
nnoremap <silent> [NeoBundle]i :<C-u>NeoBundleInstall<CR>
nnoremap <silent> [NeoBundle]c :<C-u>NeoBundleClean<CR>
nnoremap <silent> [NeoBundle]I :<C-u>NeoBundleInstall!<CR>
nnoremap <silent> [NeoBundle]u :<C-u>NeoBundleUpdate<CR>
" Unite
nnoremap [Unite] <Nop>
nmap ,u [Unite]
nnoremap <silent> [Unite]o :<C-u>Unite outline<CR>
nnoremap <silent> [Unite]r :<C-u>Unite file_mru<CR>
nnoremap <silent> [Unite]c :<C-u>Unite colorscheme -auto-preview<CR>
nnoremap <silent> [Unite]b :<C-u>Unite buffer<CR>
" 日付、現在日時の短縮入力
inoremap <Leader>date <C-R>=strftime("%Y-%m-%d")<CR>
inoremap <Leader>now <C-R>=strftime("%Y-%m-%d (%a) %H:%M")<CR>
" switch.vim
nnoremap ! :Switch<CR>

" easy open vimrc
if has("win64")
	let vimrcbody = '$HOME/_vimrc'
else
	let vimrcbody = '$HOME/.vimrc'
endif

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
" unite colorscheme
"---------------------------
let g:unite_enable_start_insert = 1
let g:unite_enable_split_vertically = 1
if globpath(&rtp, 'plugin/unite.vim') != ''
  nnoremap sc :<C-u>Unite colorscheme<CR>
endif


"---------------------------
" QFixHowm
"---------------------------
let howm_dir			= '~/Dropbox/notes/'
let QFixHowm_RootDir	= '~/Dropbox/notes/'
let howm_filename		= '%Y-%m-%d-%H%M%S.txt'
let howm_fileencoding	= 'utf-8'
let howm_fileformat		= 'unix'
let QFixHowm_FileType	= 'markdown'
let QFixHowm_SaveTime	= 2
let QFixHowm_DiaryFile	= 'diary/%Y/%m/%Y-%m-%d-000000.howm'
let QFixHowm_Title = "="
let QFixHowm_Key ="g"
let QFixHowm_KeyB = ","

" howmディレクトリをhdコマンドで変更
command! -nargs=1 Hd let howm_dir = QFixHowm_RootDir.'/'.<q-args>|echo howm_dir


"---------------------------
" Rails.vim
"---------------------------
" :Rconfigでroutes.rb表示
autocmd User Rails Rnavcommand config config   -glob=*.*  -suffix= -default=routes.rb
" Alias
autocmd User Rails nmap :<C-u>Rcontroller :<C-u>Rc
autocmd User Rails nmap :<C-u>Rmodel :<C-u>Rm
autocmd User Rails nmap :<C-u>Rview :<C-u>Rv


"---------------------------
" Neocomplete
"---------------------------
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
" prevent completefunc conflicts
let g:neocomplete#force_overwrite_completefunc = 1

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns._ = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
" <TAB> setting is later, in NeoSnippets settings
" inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> pumvisible() ? neocomplete#smart_close_popup()."\<C-h>" : "\<C-h>"
inoremap <expr><BS> pumvisible() ? neocomplete#smart_close_popup()."\<C-h>" : "\<C-h>"
inoremap <expr><C-q> pumvisible() ? neocomplete#close_popup() : "\<C-q>"
inoremap <expr><C-e> pumvisible() ? neocomplete#cancel_popup() : "\<C-e>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'


"---------------------------
" NeoSnippet
"---------------------------
" snippets
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets,~/.vim/mysnippets'

" Plugin Keymap
imap <C-k>  <Plug>(neosnippet_expand_or_jump)
smap <C-k>  <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: "\<TAB>"


"---------------------------
" emmet
"---------------------------
" トリガーをC-yに変更
let g:user_emmet_leader_key = '<C-y>'
" insert, normalモードでのみ動作
let g:user_emmet_mode = 'in'


"---------------------------
" lightline
"---------------------------
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
			\             [ 'currentdir' ],
      \             [ 'fugitive', 'filename', 'readonly', 'modified' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"\u2b64":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}'
      \ },
      \ 'component_function': {
      \   'currentdir': 'MyCurrentDir',
      \ },
      \ 'separator': { 'left': "\u2b80", 'right': "\u2b82" },
      \ 'subseparator': { 'left': "\u2b81", 'right': "\u2b83" },
      \}

function! MyCurrentDir()
	return fnamemodify(getcwd(), ":p")
endfunction

