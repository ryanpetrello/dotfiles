PATH=/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/usr/local/mongodb/bin:/brew/bin:/brew/sbin:/brew/share/npm/bin:$PATH
export NODE_PATH=/brew/lib/node

# zsh vim mode
set -o vi

# import private aliases
if [ -f ~/.alias ]; then
   source ~/.alias
fi

# other shared aliases
alias ..="cd .."

# function to determine the currently active virtualenv
function active_virtualenv() {
    if [ -z "$VIRTUAL_ENV" ]; then
        # not in a virtualenv
        return
    fi

    echo "(`basename \"$VIRTUAL_ENV\"`)"
}

# mvim as default + launch settings
export EDITOR='mvim -f -c "au VimLeave * !open -a iTerm"'

# colors
alias ls='ls -G'
export GREP_COLOR=32
alias grep='grep --color'

fg_lblue=%{$'\e[0;34m'%}
fg_lgreen=%{$'\e[1;32m'%}
fg_white=%{$'\e[1;37m'%}

# Custom status line
PS1="$(active_virtualenv)${fg_lblue}%~ ${fg_white}$ "

# I wish py.test did this by default...
alias py.test="py.test --tb=short"

# Show a + on the status line when vim mode is -- INSERT --
function zle-line-init zle-keymap-select {
    PS1="$(active_virtualenv)${fg_lblue}%~ ${fg_lgreen}${${KEYMAP/vicmd/}/(main|viins)/+}${fg_white}${${KEYMAP/vicmd/$}/(main|viins)/}${fg_white} "
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# zsh-specific tinkering
autoload -U compinit && compinit
