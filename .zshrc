export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

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
alias cat="bat"
alias ob="cd ~/vault/vault/ && nvim ."

eval "$(starship init zsh)"
source <(fzf --zsh)

. "$HOME/.cargo/env"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="~/.local/bin/:$PATH"

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/eemil/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/eemil/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/eemil/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/eemil/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
