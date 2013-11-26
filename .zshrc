PATH=/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/usr/local/mongodb/bin:/brew/bin:/brew/sbin:/brew/share/npm/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH
export NODE_PATH=/brew/lib/node

# zsh vim mode
set -o vi

# import private aliases
if [ -f ~/.alias ]; then
   source ~/.alias
fi

# other shared aliases
alias ll="ls -la"
alias cdd="cd -"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias t="tmux"

# ack-specific settings
export ACK_COLOR_MATCH='red'

# virtualenvwrapper settings
export WORKON_HOME=~/venvs
source /usr/local/bin/virtualenvwrapper.sh

# use iPython if possible
function python () {
    test -z "$1" && ipython || command python "$@"
}

# history
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
bindkey '^R' history-incremental-search-backward

# function to determine the currently active virtualenv
function active_virtualenv() {
    if [ -z "$VIRTUAL_ENV" ]; then
        # not in a virtualenv
        return
    fi

    echo "(`basename \"$VIRTUAL_ENV\"`)"
}

#
# used to print <vim> if the shell was spawned from vim (and there's an 
# active vim session waiting in the background)
#
function vim_flag() {
    if [ `ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'` = "vim" ]; then
        echo "${fg_lblue}(vim)${fg_white}"
    fi
}

# vim as default + launch settings
export EDITOR='vim'
export TERM='screen-256color'

# colors
export CLICOLOR=1
export LSCOLORS=DxDxCxDxexexexaxaxaxax
export GREP_COLOR=32
alias grep='grep --color'

fg_lblue=%{$'\e[0;34m'%}
fg_lgreen=%{$'\e[1;32m'%}
fg_yellow=%{$'\e[1;33m'%}
fg_white=%{$'\e[1;37m'%}

# I wish py.test did this by default...
alias py.test="py.test --tb=short"

setopt auto_menu
setopt complete_in_word
setopt always_to_end

# version control info
autoload -Uz vcs_info
setopt prompt_subst
setopt  globcomplete
zstyle ':vcs_info:*' stagedstr $'%F{green}●'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git svn
precmd () { 
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        zstyle ':vcs_info:*' formats $'[%{\e[1;33m%}%b%F{foreground}:%c%u%F{foreground}] '
    } else {
        zstyle ':vcs_info:*' formats $'(%{\e[1;33m%}%b%F{foreground}:%c%u%F{white}●%F{foreground}) '
    }
    vcs_info
}
local git='$vcs_info_msg_0_'

# Custom status line
PS1="$(vim_flag)$(active_virtualenv)${git}${fg_lblue}%~ ${fg_white}$ "

# Show a green $ on the status line when vim mode is -- INSERT --
function zle-line-init zle-keymap-select {
    PS1="$(vim_flag)$(active_virtualenv)${git}${fg_lblue}%~ ${fg_lgreen}${${KEYMAP/vicmd/}/(main|viins)/$}${fg_white}${${KEYMAP/vicmd/$}/(main|viins)/}${fg_white} "
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# -----------------------------------------------
# Set up zsh-specifics
# -----------------------------------------------

# compinit initializes various advanced completions for zsh
autoload -U compinit && compinit

# case insensitive tab completion
unsetopt correctall

# General completion technique
zstyle ':completion:*' completer _complete _match _approximate

# Partial color matching on TAB
autoload -U colors && colors
highlights='${PREFIX:+=(#bi)($PREFIX:t)(?)*==$color[blue]=00}':${(s.:.)LS_COLORS}}
zstyle -e ':completion:*' list-colors 'reply=( "'$highlights'" )'
zstyle -e ':completion:*:-command-:*:commands' list-colors 'reply=(
"'$highlights'" )'
unset highlights

# Auto-attach to tmux
if [ -z "$TMUX" ]; then
    # not in a tmux session
    tmux attach || tmux new
else
    # Listen for tmux clipboard changes
    while true; do
      if test -n "`tmux showb 2> /dev/null`"; then
        tmux saveb -|pbcopy && tmux deleteb
      fi
      sleep 0.5
    done &
    clear
fi

setopt AUTO_PUSHD
DIRSTACKSIZE=9
DIRSTACKFILE=~/.zdirs
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1] && cd $OLDPWD
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}
