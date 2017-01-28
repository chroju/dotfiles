"---------------------------
" encoding
"---------------------------
" http://rbtnn.hateblo.jp/entry/2014/11/30/174749
set encoding=utf-8
scriptencoding utf-8
" 保存ファイルエンコード設定
set fileencoding=utf-8
" ファイルの文字コード自動判別設定
set fileencodings=ucs-bom,utf-8,cp932,sjis,euc-jp,iso-2022-jp
" 改行コード設定
set fileformat=unix
set fileformats=unix,dos,mac


"---------------------------
" Common
"---------------------------
" reset autocmd
augroup vimrc
  autocmd!
augroup END

set number " 行数表示
set notitle " 変なタイトル表示しない
set nobackup " バックアップファイルを作成しない
set noswapfile " スワップファイルを作成しない
set hidden " 未保存バッファがあっても無視する
set clipboard+=unnamed,autoselect  " クリップボードをOSと連携
set showcmd " 入力中のコマンドを右下に表示
set ruler " 座標を右下に表示
set scrolloff=3 " スクロール時の余白確保
set textwidth=0 " 自動折り返しをしない
set noerrorbells " エラー時にビープ音を鳴らさない
set vb t_vb= " ビープ音をビジュアルベル（空文字）に置き換え
set novisualbell "ビジュアルベルを表示しない
set ambiwidth=double " マルチバイト文字のズレを防ぐ
set laststatus=2
" 以下3行、矢印キーによるアルファベット入力防止
set notimeout
set ttimeout
set timeoutlen=100
set noundofile " .un~ファイルを生成しない
set helplang=ja,en
set nrformats= " 語頭0の数値も10進数として扱う
set foldlevel=99
" デフォルト設定のtxtファイルのtextwidthを上書き
autocmd vimrc FileType text setlocal textwidth=0


"---------------------------
" dein.vim
"---------------------------

" http://qiita.com/delphinus35/items/00ff2c0ba972c6e41542
" プラグインのインストールディレクトリ
let s:dein_dir = expand('~/.vim/bundle')
" dein.vimのインストールディレクトリ
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vimが存在しない場合はインストール
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  call dein#add('Shougo/dein.vim')
  call dein#add('altercation/vim-colors-solarized')
  call dein#add('Shougo/unite.vim')
  call dein#add('ujihisa/unite-colorscheme')
  call dein#add('cocopon/iceberg.vim')
  call dein#add('scrooloose/nerdtree')
  call dein#add('joker1007/vim-markdown-quote-syntax')
  call dein#add('thinca/vim-quickrun')
  call dein#add('tomtom/tcomment_vim.git')
  call dein#add('Shougo/neocomplete.vim')
  call dein#add('tpope/vim-surround')
  call dein#add('choplin/unite-vim_hacks')
  call dein#add('vim-ruby/vim-ruby')
  call dein#add('vim-scripts/Align')
  call dein#add('vim-scripts/YankRing.vim')
  call dein#add('vim-scripts/Changed')
  call dein#add('itchyny/lightline.vim')
  call dein#add('groenewege/vim-less')
  call dein#add('glidenote/memolist.vim')
  call dein#add('vim-jp/vimdoc-ja')
  call dein#add('jacquesbh/vim-showmarks')
  call dein#add('thinca/vim-ref')
  call dein#add('yuku-t/vim-ref-ri')
  call dein#add('kchmck/vim-coffee-script')
  call dein#add('glidenote/serverspec-snippets')
  call dein#add('lambdalisue/vim-gista')
  call dein#add('davidhalter/jedi-vim')

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

" %移動設定
if !exists('loaded_matchit')
  runtime macros/matchit.vim
endif


"---------------------------
" Visual
"---------------------------
"カラースキーム設定
colorscheme iceberg
highlight Normal ctermbg=none
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
highlight clear CursorLine
highlight CursorLine ctermbg=17 guibg=black
" カーソルライン設定ここまで

" スペルチェックに下線を引く
highlight SpellBad cterm=underline ctermbg=0


"---------------------------
" Search
"---------------------------
set incsearch "インクリメンタルサーチを行う
set hlsearch  "検索結果をハイライトする
set ignorecase  "検索時に文字の大小を区別しない
set smartcase "検索時に大文字を含んでいたら大小を区別する
set wrapscan  "検索をファイルの先頭へループする

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
"長い行も最後まで表示する
set display=lastline
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
" Key mapping
"---------------------------
" common
nnoremap ,, :up<CR>
nnoremap <Space>,, :w<Space>!sudo<Space>tee<Space>>/dev/null<Space>%
nnoremap <C-h> :<C-u>help<Space>
nnoremap <Space>l $
nnoremap <Space>h ^
vnoremap <Space>l $
vnoremap <Space>h ^
nnoremap Y y$

" インクリメント＆デクリメント
nnoremap + <C-a>
nnoremap - <C-p>

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

" plugins
" NERDTreeToggleをF6に割り当て
nnoremap <F6> :NERDTreeToggle<CR>
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
" plugins
"---------------------------
"## unite colorscheme
let g:unite_enable_start_insert = 1
let g:unite_enable_split_vertically = 1
if globpath(&rtp, 'plugin/unite.vim') != ''
  nnoremap sc :<C-u>Unite colorscheme<CR>
endif


"## memolist
" memolist directory path
let g:memolist_path = "$HOME/Dropbox/notes"
" use template
let g:memolist_template_dir_path = "$HOME/.vim/templates/memolist.txt"
" suffix type (default markdown)
let g:memolist_memo_suffix = "md"
" date format (default %Y-%m-%d %H:%M)
let g:memolist_memo_date = "%Y-%m-%d %H:%M"
" use qfixgrep (default 0)
let g:memolist_qfixgrep = 1
" use unite (default 0)
let g:memolist_unite = 1
let g:memolist_unite_source = "file_rec"
let g:memolist_unite_option = "-auto-preview -start-insert"
nnoremap ,mn  :MemoNew<CR>
nnoremap ,ml  :MemoList<CR>
nnoremap ,mg  :MemoGrep<Space>


"## Rails.vim
" :Rconfigでroutes.rb表示
autocmd vimrc User Rails Rnavcommand config config   -glob=*.*  -suffix= -default=routes.rb
" Alias
autocmd vimrc User Rails nmap :<C-u>Rcontroller :<C-u>Rc
autocmd vimrc User Rails nmap :<C-u>Rmodel :<C-u>Rm
autocmd vimrc User Rails nmap :<C-u>Rview :<C-u>Rv


"## neocomplete
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
    \ 'scheme' : $HOME.'/.gosh_completions',
    \ 'ruby' : $VIMHOME.'/dict/ruby.dict'
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
autocmd vimrc FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd vimrc FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd vimrc FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd vimrc FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd vimrc FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" if !exists('g:neocomplete#force_omni_input_patterns')
"   let g:neocomplete#force_omni_input_patterns = {}
" endif
" let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'


"## NeoSnippet
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


"## emmet
" トリガーをC-yに変更
let g:user_emmet_leader_key = '<C-y>'
" insert, normalモードでのみ動作
let g:user_emmet_mode = 'in'


"## lightline
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
      \ 'separator': { 'left': "", 'right': "" },
      \ 'subseparator': { 'left': "|", 'right': "|" },
      \}

function! MyCurrentDir()
  return fnamemodify(getcwd(), ":p:~")
endfunction


"## OpenBrowser
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nnoremap gx <Plug>(openbrowser-smart-search)
vnoremap gx <Plug>(openbrowser-smart-search)


"## for coffeescript
" http://qiita.com/alpaca_taichou/items/fb442cfa78f91634cfaa
au BufRead,BufNewFile,BufReadPre *.coffee   set filetype=coffee
" 保存時にコンパイル
" autocmd BufWritePost *.coffee silent CoffeeMake! -cb | cwindow | redraw!
