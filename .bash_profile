export PATH=$PATH:/Applications/eclipse/sdk/platform-tools:/Applications/eclipse/sdk/tools:/usr/local/bin:/usr/local/sbin

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env_LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
 
