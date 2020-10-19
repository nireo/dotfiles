#
# ~/.bashrc
#

export PATH="/home/eemil/.cargo/bin:$PATH"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [[ $TERM == "linux" ]]; then
    echo -en "\033]P0000000" # black
    echo -en "\033]P85e5e5e" # darkgray
    echo -en "\033]P18a2f58" # darkred
    echo -en "\033]P9cf4f88" # lightred
    echo -en "\033]P2287373" # darkgreen
    echo -en "\033]Pa53a6a6" # lightgreen
    echo -en "\033]P3914e89" # darkyellow
    echo -en "\033]Pbbf85cc" # lightyellow
    echo -en "\033]P4395573" # darkblue
    echo -en "\033]Pc4779b3" # lightblue
    echo -en "\033]P55e468c" # darkmagenta
    echo -en "\033]Pd7f62b3" # lightmagenta
    echo -en "\033]P62b7694" # darkcyan
    echo -en "\033]Pe47959e" # lightcyan
    echo -en "\033]P7899ca1" # lightgray
    echo -en "\033]Pfc0c0c0" # white
fi

export TERM=xterm-256color
export EDITOR=/usr/bin/nvim

function cu {
    local count=$1
    if [ -z "${count}" ]; then
        count=1
    fi
    local path=""
    for i in $(seq 1 ${count}); do
        path="${path}../"
    done
    cd $path
}


# Added colors
alias ls='ls --color=auto'
alias grep="grep --color=auto"
alias l='ls --color=auto'

alias nvimconf="nvim ~/.config/nvim/init.vim"
alias goprojects="cd ~/go/src/github.com/nireo"

# Package
alias install="sudo pacman -S"
alias update="sudo pacman -Syu"
alias delete="sudo pacman -Rs"

# Git
alias save-a="git add ."
alias save="git add"
alias commit="git commit -m"
alias push-m="git push -u origin master"
alias clone="git clone"
alias untar="tar xvf"

alias g='g++ -std=c++11 -O2 -Wall'

PS1='\u (\W): '


