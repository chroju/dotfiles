# env_var
export TERM=xterm-256color
export SHELL=zsh
export EDITOR=vim
export LANG=ja_JP.UTF-8
PATH=(
  $HOME/.rbenv/bin(N-/)
  /usr/local/opt/coreutils/libexec/gnubin(N-/)
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  $PATH
)

# rbenv init
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
