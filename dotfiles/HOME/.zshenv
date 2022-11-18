setopt no_global_rcs

# ====================
#  setting env vars
# ====================

export TERM=xterm-256color
export SHELL=/bin/zsh
export EDITOR=vim
export LANG=ja_JP.UTF-8
export GOPATH=$HOME/dev
export AWS_DEFAULT_REGION=ap-northeast-1
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_password


# ====================
#  setting PATH
# ====================

typeset -U path
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/local/opt/coreutils/libexec/gnubin(N-/)
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /usr/local/heroku/bin(N-/)
  /usr/local/go/bin(N-/)
  /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/(N-/)
  /usr/local/texlive/2019/bin/x86_64-darwin/(N-/)
  $GOPATH/bin(N-/)
  $path
)
