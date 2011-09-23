PATH=/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/usr/local/mongodb/bin:/brew/bin:/brew/sbin:/brew/share/npm/bin:$PATH

set -o vi

if [ -f ~/.alias ]; then
   source ~/.alias
fi

function active_virtualenv() {
    if [ -z "$VIRTUAL_ENV" ]; then
        # not in a virtualenv
        return
    fi

    echo "(`basename \"$VIRTUAL_ENV\"`) "
}

export NODE_PATH=/brew/lib/node
export EDITOR='mvim -f -c "au VimLeave * !open -a iTerm"'

# color
alias ls='ls -G'
alias vim='mvim -c "au VimLeave * !open -a iTerm"'

export GREP_COLOR=32
alias grep='grep --color'

fg_lblue=%{$'\e[0;34m'%}
fg_lgreen=%{$'\e[1;32m'%}
fg_white=%{$'\e[1;37m'%}
PS1="$(active_virtualenv)${fg_lblue}%~ ${fg_white}$ "

alias ..="cd .."

# I wish py.test did this by default...
alias py.test="py.test --tb=short"

function zle-line-init zle-keymap-select {
    PS1="$(active_virtualenv)${fg_lblue}%~ ${fg_lgreen}${${KEYMAP/vicmd/$}/(main|viins)/+}${fg_white} "
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# zsh-specific
autoload -U compinit && compinit
