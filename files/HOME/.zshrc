
# ====================
#  common
# ====================

# 色指定有効化
autoload -U colors && colors
# 単語の一部として扱われる文字のセット
WORDCHARS='*_-'


# ====================
#  alias
# ====================

alias hi='history -i'
alias lsg='ls -G --color'
alias ll='ls -la'
alias grepe='grep --color -E'
alias g='git '
alias t='terraform'
alias k='kubectl'
alias -g G=' | grep --color -E'
alias -g M=' | more'
alias -g H=' | head'
alias -g T=' | tail'
alias -g L=' | less'


# ====================
#  key binds
# ====================

# emacsライクなキーバインド
bindkey -e
# bash同様にキーバインド
bindkey '^U' backward-kill-line
bindkey '^]' vi-find-next-char
bindkey '^[^]' vi-find-prev-char


# ====================
#  options
# ====================

# 入力したコマンドが存在せず、かつディレクトリ名と一致するなら、ディレクトリに cd する
setopt auto_cd
# cd した先のディレクトリをディレクトリスタックに追加する
setopt auto_pushd
# pushd 実行時にディレクトリスタックの内容を出力しない
setopt PUSHDSILENT
# 曖昧補完
setopt auto_list
# 変数名補完
setopt auto_param_keys
# ディレクトリ名末尾のスラッシュを自動補完する
setopt auto_param_slash
# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups
# 語末ではなくカーソル位置でtab補完
setopt complete_in_word
# 拡張 glob を有効にする
setopt extended_glob
# historyに実行時刻追加
setopt extended_history
# 入力したコマンドがすでにコマンド履歴に含まれる場合、履歴から古いほうのコマンドを削除する
setopt hist_ignore_all_dups
# コマンドがスペースで始まる場合、コマンド履歴に追加しない
setopt hist_ignore_space
# historyにhistoryコマンド自体を記録しない
setopt hist_no_store
# historyをzshプロセス間で共有
setopt share_history
# 補完リストを小さく表示
setopt list_packed
# 補完対象ファイルリストの末尾に識別マークを付ける
setopt list_types
# rm * する際に10秒待つ
setopt rm_star_wait
# コマンドスペル訂正
setopt correct
# ビープを出さない
setopt no_beep
# 先頭が.のファイルを*対象に含める
setopt glob_dots
# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst
# 対話式シェルでも先頭がシャープであればコメントにする
setopt interactive_comments
# /etc配下のzsh関連ファイルを実行しない
setopt no_global_rcs


# ====================
#  history
# ====================

HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000


# ====================
#  prompt
# ====================

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst
# gitの情報表示
autoload -U vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{green}[!]'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}[+]'
zstyle ':vcs_info:*' formats 'on %F{green}%r:%b%f %c%u'
zstyle ':vcs_info:*' actionformats  'on %F{green}%r:%b%f %c%u %F{red}<%a>%f'
precmd () { vcs_info }
# プロンプト
PROMPT='
%{$fg[green]%}%n%{${reset_color}%} in %{$fg[yellow]%}%m%{${reset_color}%} at %{$fg[cyan]%}%d%{${reset_color}%} ${vcs_info_msg_0_}
%(?.%{$fg[white]%}.%{$fg[cyan]%})%(?!:%)!:()%{${reset_color}%} '
SPROMPT="%{$fg[magenta]%}%{$suggest%};%) < Ist es %B%r%b %{$fg[magenta]%}? [Ja!(y), Nein!(n),a,e]:${reset_color} "


# ====================
#  completion
# ====================

# 自動補完を有効にする
autoload -U compinit && compinit

# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
# 候補を選ぶには <Tab> か Ctrl-N,B,F,P
zstyle ':completion:*:default' menu select=2
# カレントディレクトリに候補がない場合のみ cdpath 上のディレクトリを候補に出す
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
# 大文字、小文字を区別せず補完する
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# コマンドにsudoを付けても補完
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
# 補完をカラー化
zstyle ':completion:*' list-colors "${LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _history _prefix
## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zshcache
# 変数の添字を補完する
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*' format '%B%d%b'

# 前方一致での履歴補完有効化
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end


# ====================
#  functions
# ====================

gcr () {
  if [[ $# != 1 ]]; then
    echo "ERROR"
  else
    local REPO=$1
    local REPO_PATH="$(ghq root)/github.com/chroju/${REPO}"
    mkdir $REPO_PATH
    cd $REPO_PATH
    git init
    hub create
  fi
}

notice () {
  terminal-notifier -message $1 -title 'Terminal notifier'
}


# ====================
#  load some tools
# ====================

# ssh-agent

case "${OSTYPE}" in
  linux*)
    if which ssh-agent; then
      eval `ssh-agent`
      ssh-add
    fi
    ;;
esac

# iterm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
# aws-cli
source /usr/local/share/zsh/site-functions/aws_zsh_completer.sh
# fzf
test -f ~/.fzf.zsh && source ~/.fzf.zsh
# tmux
# https://qiita.com/ssh0/items/a9956a74bff8254a606a
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  echo ""
elif [[ ! -n $TMUX && $- == *l* ]]; then
  # get the IDs
  ID="`tmux list-sessions`"
  if [[ -z "$ID" ]]; then
    tmux new-session
  fi
  create_new_session="Create New Session"
  ID="$ID\n${create_new_session}:"
  ID="`echo $ID | $PERCOL | cut -d: -f1`"
  if [[ "$ID" = "${create_new_session}" ]]; then
    tmux new-session
  elif [[ -n "$ID" ]]; then
    tmux attach-session -t "$ID"
  else
    :  # Start terminal normally
  fi
fi
# starship
eval "$(starship init zsh)"
# direnv
eval "$(direnv hook zsh)"
# asdf
source $(brew --prefix asdf)/asdf.sh

