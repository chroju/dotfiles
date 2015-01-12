#Created by newuser for 5.0.6
#
# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# $B4D6-JQ?t(B
export TERM=xterm-256color
export PATH=$HOME/.rbenv/shims:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/local/sbin:$PATH
export SHELL=/usr/local/bin/zsh

# alias
# case ${OSTYPE} in
#   darwin*)
#     alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
# esac
alias ls='ls --color'
alias grep='grep --color -n'


# $B%W%m%s%W%H(B
PROMPT='
%B%F{blue}%n%f%b@%M %B%(?,$,%F{red}$%f)%b '
RPROMPT='%F{yellow}%~%f'

# http://qiita.com/uasi/items/c4288dd835a65eb9d709
# emacs$B%i%$%/$J%-!<%P%$%s%I(B
bindkey -e

# $B<+F0Jd40$rM-8z$K$9$k(B
# $B%3%^%s%I$N0z?t$d%Q%9L>$rESCf$^$GF~NO$7$F(B <Tab> $B$r2!$9$H$$$$46$8$KJd40$7$F$/$l$k(B
# $BNc!'(B `cd path/to/<Tab>`, `ls -<Tab>`
autoload -U compinit; compinit

# $BF~NO$7$?%3%^%s%I$,B8:_$;$:!"$+$D%G%#%l%/%H%jL>$H0lCW$9$k$J$i!"%G%#%l%/%H%j$K(B cd $B$9$k(B
# $BNc!'(B /usr/bin $B$HF~NO$9$k$H(B /usr/bin $B%G%#%l%/%H%j$K0\F0(B
setopt auto_cd

# $B",$r@_Dj$9$k$H!"(B .. $B$H$@$1F~NO$7$?$i(B1$B$D>e$N%G%#%l%/%H%j$K0\F0$G$-$k$N$G!D!D(B
# 2$B$D>e!"(B3$B$D>e$K$b0\F0$G$-$k$h$&$K$9$k(B
alias ...='cd ../..'
alias ....='cd ../../..'

# "~hoge" $B$,FCDj$N%Q%9L>$KE83+$5$l$k$h$&$K$9$k!J%V%C%/%^!<%/$N$h$&$J$b$N!K(B
# $BNc!'(B cd ~hoge $B$HF~NO$9$k$H(B /long/path/to/hogehoge $B%G%#%l%/%H%j$K0\F0(B
hash -d hoge=/long/path/to/hogehoge

# cd $B$7$?@h$N%G%#%l%/%H%j$r%G%#%l%/%H%j%9%?%C%/$KDI2C$9$k(B
# $B%G%#%l%/%H%j%9%?%C%/$H$O:#$^$G$K9T$C$?%G%#%l%/%H%j$NMzNr$N$3$H(B
# `cd +<Tab>` $B$G%G%#%l%/%H%j$NMzNr$,I=<($5$l!"$=$3$K0\F0$G$-$k(B
setopt auto_pushd

# pushd $B$7$?$H$-!"%G%#%l%/%H%j$,$9$G$K%9%?%C%/$K4^$^$l$F$$$l$P%9%?%C%/$KDI2C$7$J$$(B
setopt pushd_ignore_dups

# $B3HD%(B glob $B$rM-8z$K$9$k(B
# glob $B$H$O%Q%9L>$K%^%C%A$9$k%o%$%k%I%+!<%I%Q%?!<%s$N$3$H(B
# $B!J$?$H$($P(B `mv hoge.* ~/dir` $B$K$*$1$k(B "*"$B!K(B
# $B3HD%(B glob $B$rM-8z$K$9$k$H(B # ~ ^ $B$b%Q%?!<%s$H$7$F07$o$l$k(B
# $B$I$&$$$&0UL#$r;}$D$+$O(B `man zshexpn` $B$N(B FILENAME GENERATION $B$r;2>H(B
setopt extended_glob

# $BF~NO$7$?%3%^%s%I$,$9$G$K%3%^%s%IMzNr$K4^$^$l$k>l9g!"MzNr$+$i8E$$$[$&$N%3%^%s%I$r:o=|$9$k(B
# $B%3%^%s%IMzNr$H$O:#$^$GF~NO$7$?%3%^%s%I$N0lMw$N$3$H$G!">e2<%-!<$G$?$I$l$k(B
setopt hist_ignore_all_dups

# $B%3%^%s%I$,%9%Z!<%9$G;O$^$k>l9g!"%3%^%s%IMzNr$KDI2C$7$J$$(B
# $BNc!'(B <Space>echo hello $B$HF~NO(B
setopt hist_ignore_space

autoload -U compinit
compinit
setopt correct
setopt nobeep
# <Tab> $B$G%Q%9L>$NJd408uJd$rI=<($7$?$"$H!"(B
# $BB3$1$F(B <Tab> $B$r2!$9$H8uJd$+$i%Q%9L>$rA*Br$G$-$k$h$&$K$J$k(B
# $B8uJd$rA*$V$K$O(B <Tab> $B$+(B Ctrl-N,B,F,P
zstyle ':completion:*:default' menu select=1
#$BBgJ8;z!">.J8;z$r6hJL$;$:Jd40$9$k(B
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
#$BJd40$G%+%i!<$r;HMQ$9$k(B
autoload colors
zstyle ':completion:*' list-colors "${LS_COLORS}"

# $BC18l$N0lIt$H$7$F07$o$l$kJ8;z$N%;%C%H$r;XDj$9$k(B
# $B$3$3$G$O%G%U%)%k%H$N%;%C%H$+$i(B / $B$rH4$$$?$b$N$H$9$k(B
# $B$3$&$9$k$H!"(B Ctrl-W $B$G%+!<%=%kA0$N(B1$BC18l$r:o=|$7$?$H$-!"(B / $B$^$G$G:o=|$,;_$^$k(B
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
