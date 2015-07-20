#Created by newuser for 5.0.6
#
# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# 環境変数
export TERM=xterm-256color
export PATH=$HOME/.rbenv/shims:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/local/sbin:$PATH
export SHELL=/usr/local/bin/zsh

# alias
# case ${OSTYPE} in
#   darwin*)
#     alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
# esac
alias vi='vim'
alias ls='ls --color'
alias ll='ls -la'
alias grep='grep --color -n'
alias -g G=' | grep --color -n'
alias -g M=' | more'
alias -g H=' | head'
alias -g T=' | tail'

# 色設定
autoload -U colors; colors

# もしかして機能
setopt correct

# PCRE 互換の正規表現を使う
setopt re_match_pcre

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst
# プロンプト
# PROMPT='
# %B%F{blue}%n%f%b@%M %B%(?,$,%F{red}$%f)%b '
PROMPT="
%{$fg[yellow]%}%m%{${reset_color}%}
%(?.%{$fg[white]%}.%{$fg[cyan]%})%(?!|-'%)!|-;%))%{${reset_color}%} "
SPROMPT="%{$fg[magenta]%}%{$suggest%}|*'~'? < is it %B%r%b %{$fg[magenta]%}? [Yes!(y), No!(n),a,e]:${reset_color} "
RPROMPT='%F{yellow}%~%f'
# http://qiita.com/uasi/items/c4288dd835a65eb9d709
# emacsライクなキーバインド
bindkey -e

# 自動補完を有効にする
# コマンドの引数やパス名を途中まで入力して <Tab> を押すといい感じに補完してくれる
# 例： `cd path/to/<Tab>`, `ls -<Tab>`
autoload -U compinit; compinit

# 入力したコマンドが存在せず、かつディレクトリ名と一致するなら、ディレクトリに cd する
# 例： /usr/bin と入力すると /usr/bin ディレクトリに移動
setopt auto_cd

# ↑を設定すると、 .. とだけ入力したら1つ上のディレクトリに移動できるので……
# 2つ上、3つ上にも移動できるようにする
alias ...='cd ../..'
alias ....='cd ../../..'

# "~hoge" が特定のパス名に展開されるようにする（ブックマークのようなもの）
# 例： cd ~hoge と入力すると /long/path/to/hogehoge ディレクトリに移動
hash -d hoge=/long/path/to/hogehoge

# cd した先のディレクトリをディレクトリスタックに追加する
# ディレクトリスタックとは今までに行ったディレクトリの履歴のこと
# `cd +<Tab>` でディレクトリの履歴が表示され、そこに移動できる
setopt auto_pushd

# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups

# 拡張 glob を有効にする
# glob とはパス名にマッチするワイルドカードパターンのこと
# （たとえば `mv hoge.* ~/dir` における "*"）
# 拡張 glob を有効にすると # ~ ^ もパターンとして扱われる
# どういう意味を持つかは `man zshexpn` の FILENAME GENERATION を参照
setopt extended_glob

# 入力したコマンドがすでにコマンド履歴に含まれる場合、履歴から古いほうのコマンドを削除する
# コマンド履歴とは今まで入力したコマンドの一覧のことで、上下キーでたどれる
setopt hist_ignore_all_dups

# コマンドがスペースで始まる場合、コマンド履歴に追加しない
# 例： <Space>echo hello と入力
setopt hist_ignore_space

setopt correct
setopt nobeep
# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
# 候補を選ぶには <Tab> か Ctrl-N,B,F,P
zstyle ':completion:*:default' menu select=1
#大文字、小文字を区別せず補完する
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
#補完でカラーを使用する
autoload colors
zstyle ':completion:*' list-colors "${LS_COLORS}"

# 単語の一部として扱われる文字のセットを指定する
# ここではデフォルトのセットから / を抜いたものとする
# こうすると、 Ctrl-W でカーソル前の1単語を削除したとき、 / までで削除が止まる
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
