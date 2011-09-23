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
fg_yellow=%{$'\e[1;33m'%}
fg_white=%{$'\e[1;37m'%}

# I wish py.test did this by default...
alias py.test="py.test --tb=short"

# version control info
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' stagedstr '%F{green}●'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git svn
precmd () { 
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        zstyle ':vcs_info:*' formats '(%F{red}%b%F{white}:%c%u%F{foreground}) '
    } else {
        zstyle ':vcs_info:*' formats '(%F{red}%b%F{white}:%c%u%F{white}●%F{foreground}) '
    }
    vcs_info
}
local git='$vcs_info_msg_0_'

# Custom status line
PS1="$(active_virtualenv)${git}${fg_lblue}%~ ${fg_white}$ "

# Show a + on the status line when vim mode is -- INSERT --
function zle-line-init zle-keymap-select {
    PS1="$(active_virtualenv)${git}${fg_lblue}%~ ${fg_lgreen}${${KEYMAP/vicmd/}/(main|viins)/+}${fg_white}${${KEYMAP/vicmd/$}/(main|viins)/}${fg_white} "
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# zsh-specific tinkering
autoload -U compinit && compinit
