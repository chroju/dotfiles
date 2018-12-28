# ====================
#  setting env vars
# ====================

export TERM=xterm-256color
export SHELL=zsh
export EDITOR=vim
export LANG=ja_JP.UTF-8
export GOPATH=$HOME/go


# ====================
#  setting PATH
# ====================

typeset -U path
path=(
  $HOME/.rbenv/bin(N-/)
  /usr/local/opt/coreutils/libexec/gnubin(N-/)
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /usr/local/heroku/bin(N-/)
  /usr/local/go/bin(N-/)
  /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/(N-/)
  $GOPATH/bin(N-/)
  $path
)

# rbenv init
which rbenv > /dev/null && eval "$(rbenv init - zsh)"

