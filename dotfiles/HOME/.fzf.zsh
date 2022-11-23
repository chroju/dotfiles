#!/bin/bash
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
if [ $(uname -m) = 'arm64' ]; then
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
else
  source "/usr/local/opt/fzf/shell/key-bindings.zsh"
fi

# customize

# alias fzf='fzf-tmux --layout=reverse -r 20%'
# export FZF_TMUX=1
export FZF_DEFAULT_OPTS='--layout=reverse'

fghq() {
  local dir
  dir=$(ghq list > /dev/null | fzf +m) &&
    cd $(ghq root)/$dir
}

fgitbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

fd() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m ) && cd "$dir"
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

tfdoc() {
  if [[ $1 ]]; then
    r=$(curl -sL "https://api.github.com/repos/terraform-providers/terraform-provider-${1}/contents/website/docs/r/" | jq -r ".[].name" | cut -d '.' -f 1 | fzf)
    if [[ $r ]]; then
      open https://www.terraform.io/docs/providers/${1}/r/${r}.html
    fi
  else
    echo "ERROR: specify provider"
  fi
}

adoc() {
  local module
  module=$(ansible-doc -l | awk '{print $1}' | fzf +m) && open "https://docs.ansible.com/ansible/latest/modules/${module}_module.html"
}

_fzf_complete_aws-vault() {
  _fzf_complete --reverse -- "$@" < <(aws configure list-profiles)
}

_fzf_complete_doge() {
  _fzf_complete --multi --reverse --prompt="doge> " -- "$@" < <(
    echo very
    echo wow
    echo such
    echo doge
  )
}

zmodload zsh/mapfile

fstash() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    mapfile -t out <<< "$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break;
    else
      git stash show -p $sha
    fi
  done
}
