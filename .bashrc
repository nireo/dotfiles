# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

export EDITOR=nvim

PS1='(\W) -> '

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

useflag() {
    local file="$1"
    shift

    local pkg="$1"
    shift

    local flags="$*"

    if [[ -z "$file" || -z "$pkg" || -z "$flags" ]]; then
        echo "Usage: useflag <file> <package> <flags...>"
        echo "Example: useflag qt dev-qt/qtbase opengl"
        return 1
    fi

    if [[ ! "$file" =~ ^/ ]]; then
        file="/etc/portage/package.use/$file"
    fi

    sudo mkdir -p "$(dirname "$file")"
    sudo touch "$file"

    if sudo grep -q "^$pkg " "$file"; then
        echo "$pkg already exists in $file"
        return 0
    fi

    if [[ $EUID -ne 0 ]]; then
        echo "$pkg $flags" | sudo tee -a "$file" > /dev/null
    else
        echo "$pkg $flags" >> "$file"
    fi

    echo "added: $pkg $flags → $file"
}  

fe() {
    local file
    file=$(fd --hidden "$1" | fzf) || return
    [ -z "$file" ] && return
    "$EDITOR" "$file"
}

fei() {
    local file
    file=$(fd --hidden --no-ignore "$1" | fzf) || return
    [ -z "$file" ] && return
    "$EDITOR" "$file"
}

bb() {
  local file page

  file=$(fd . "$HOME/books" -t f | fzf) || return

  [ -z "$file" ] && return

  btrc "$file"

  printf 'what page did you leave on? (blank = do not update) '
  read -r page

  if [ -n "$page" ]; then
    btrc save "$file" "$page"
  fi
}

# =============================================================================
#
# To initialize zoxide, add this to your shell configuration file (usually ~/.bashrc):
#
eval "$(zoxide init bash)"

# Keep a large number of commands in memory
HISTSIZE=50000

# Allow a large number of commands to be saved to ~/.bash_history
HISTFILESIZE=100000

# Avoid duplicates and ignore commands starting with space
HISTCONTROL=ignoredups:ignorespace

# Append to history instead of overwriting
shopt -s histappend

export VCPKG_ROOT="$HOME/dev/vcpkg"
export PATH="$VCPKG_ROOT:$PATH"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOBIN
export PATH=$PATH:$HOME/.local/bin

alias padd="sudo emerge --ask --verbose --quiet"
alias pup="sudo emerge --ask --quiet --verbose --update --deep --newuse @world"
alias pdel="sudo emerge --ask --verbose --depclean"
alias ob="cd ~/vault/vault/"
alias pu="git push"
alias sc="git add . && git commit -m"
alias n="nvim"
alias ng="nvim +Neogit"
alias l="ls -al --color=auto"
alias ls="ls -a --color=auto"
