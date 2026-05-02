export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
export HOMEBREW_NO_ANALYTICS=1

plugins=(git)

source $ZSH/oh-my-zsh.sh
eval "$(zoxide init zsh)"

export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOBIN
export PATH=$PATH:$HOME/.local/bin

alias sc="git add . && git commit -m"
alias pu="git push"
alias cd="z"
alias ng="nvim +Neogit"
alias ob="cd ~/vault/vault/ && nvim ."
alias obf="cd ~/vault/vault/ && nvim \"+lua require('fff').live_grep()\""
alias pup="brew update && brew upgrade && brew cleanup"
alias audio="yt-dlp -f bestaudio -x --audio-format best --audio-quality 0 --embed-thumbnail --embed-metadata"

pdel() {
    brew uninstall "$@" && brew autoremove && brew cleanup
}

eval "$(starship init zsh)"
source <(fzf --zsh)

autoload -Uz add-zsh-hook
print_osc7() {
    printf '\033]7;file://%s%s\033\\' "$HOST" "$PWD"
}
print_osc133_prompt_start() {
    printf '\033]133;A\007'
}
print_osc133_prompt_end() {
    printf '\033]133;B\007'
}
add-zsh-hook precmd print_osc7
add-zsh-hook chpwd print_osc7
add-zsh-hook precmd print_osc133_prompt_start
add-zsh-hook preexec print_osc133_prompt_end

. "$HOME/.cargo/env"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="~/.local/bin/:$PATH"

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

obsync() {
    cd ~/vault/vault || { echo "Error: ~/vault/vault directory not found"; return 1; }

    if [[ -n $(git status --porcelain) ]]; then
        echo "changes detected in vault/vault. syncing..."
        
        git add -A
        git commit -m "sync vault"
        git push
        
        echo "vault successfully synced."
    else
        echo "no changes to sync."
    fi

    cd - > /dev/null
}

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/eemil/.opam/opam-init/init.zsh' ]] || source '/Users/eemil/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

# bun completions
[ -s "/Users/eemil/.bun/_bun" ] && source "/Users/eemil/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
eval "$(/Users/eemil/.local/bin/mise activate zsh)"
