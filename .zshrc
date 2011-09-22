PATH=/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/usr/local/mongodb/bin:/brew/bin:/brew/sbin:/brew/share/npm/bin:$PATH

set -o vi

if [ -f ~/.alias ]; then
   source ~/.alias
fi

# include zsh-git-prompt
source .zsh-git-prompt/zshrc.sh

export NODE_PATH=/brew/lib/node
export EDITOR='mvim -f -c "au VimLeave * !open -a iTerm"'

# color
alias ls='ls -G'
alias vim='mvim -c "au VimLeave * !open -a iTerm"'

export GREP_COLOR=32
alias grep='grep --color'

    PS1=$'\033[35m$(git_super_status)\033[36m%n\033[m@\033[32m%m:\033[33;1m%~\033[m${${KEYMAP/vicmd/%%}/(main|viins)/+} '

alias ..="cd .."

# I wish py.test did this by default...
alias py.test="py.test --tb=short"

function zle-line-init zle-keymap-select {
    PS1=$'\033[35m$(git_super_status)\033[36m%n\033[m@\033[32m%m:\033[33;1m%~\033[m${${KEYMAP/vicmd/%%}/(main|viins)/+} '
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
