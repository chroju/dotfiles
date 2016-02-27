# env_var
export TERM=xterm-256color
export SHELL=zsh
export EDITOR=vim
export LANG=ja_JP.UTF-8
export GOPATH=$HOME/.go
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

# aws cli
completer=$(type aws_zsh_completer.sh | sed -e 's/^.* is (.*)$/\1/g')
if [[ -e ${completer} ]]; then
  source ${completer}
fi

# ssh agent
if which ssh-agent; then
  eval `ssh-agent`
  ssh-add
fi
