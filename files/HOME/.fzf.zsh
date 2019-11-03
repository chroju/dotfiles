# default config

# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/usr/local/opt/fzf/shell/key-bindings.zsh"

# customize

alias fzf='fzf-tmux --layout=reverse -r 20%'
export FZF_TMUX=1
export FZF_DEFAULT_OPTS='--layout=reverse'

fghq() {
  local dir
  dir=$(ghq list > /dev/null | fzf-tmux --reverse +m) &&
    cd $(ghq root)/$dir
}

fgitbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

fcd() {
  dir_no=$(dirs -v | fzf | cut -f 1)
  if [[ $dir_no -ne "" ]]; then
    pushd +$dir_no
  fi
}

ffcd() {
  local depth dir
  if [[ $1 -ne "" ]]; then
    depth=$1
  else
    depth=1
  fi
  dir=$(find . -d $depth -type d | sort | fzf) && cd $dir
}
