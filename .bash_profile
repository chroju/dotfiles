export PATH=$PATH:/Applications/eclipse/sdk/platform-tools:/Applications/eclipse/sdk/tools:/usr/local/bin:/usr/local/sbin
export EDITOR=/usr/bin/vim

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'

# tmux
PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'
