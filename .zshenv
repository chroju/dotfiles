# env_var
export TERM=xterm-256color
export SHELL=zsh
export EDITOR=vim
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

typeset -U path
path=(
  $HOME/.rbenv/bin(N-/)
  /usr/local/opt/coreutils/libexec/gnubin(N-/)
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /usr/local/heroku/bin(N-/)
  /usr/local/go/bin(N-/)
  $GOPATH/bin(N-/)
  $path
)

# rbenv init
which rbenv > /dev/null && eval "$(rbenv init - zsh)"

