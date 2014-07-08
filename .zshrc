PATH=/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/usr/local/mongodb/bin:/brew/bin:/brew/sbin:/brew/share/npm/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH
export NODE_PATH=/brew/lib/node

# zsh vim mode
set -o vi

# vim text object support
source ~/.zsh/opp.zsh/opp.zsh
source ~/.zsh/opp.zsh/opp/*.zsh

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
alias ssh="~/ssh"

# Always open mutt in ~/Desktop so that downloaded mail attachments save there
alias mutt='cd ~/Desktop && mutt'

# CLI for 1Password.  Requires the `1pass` Python package
function 1pass() { command 1pass --fuzzy "$@" | tr -d '\012\015' | pbcopy }
alias 1p='1pass'

# emulated watch command
function watch {
    while :; do clear; date; echo; $@; sleep 1; done
}

function gh-diff() {
    git config --get remote.origin.url | grep $1/$2.git > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        mktmpenv
        git clone https://github.com/$1/$2.git
        cd $2
    fi
    curl https://github.com/$1/$2/pull/$3.diff | cdiff -s
}

# ack-specific settings
export ACK_COLOR_MATCH='red'

# virtualenvwrapper settings
export WORKON_HOME=~/venvs
VIRTUALENVWRAPPER=/usr/local/bin/virtualenvwrapper.sh
if [[ -f $VIRTUALENVWRAPPER ]]; then
    source $VIRTUALENVWRAPPER
fi

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
h() { if [ -z "$*" ]; then history 1; else history 1 | egrep "$@"; fi; }

# function to determine the currently active virtualenv
function active_virtualenv() {
    if [ -z "$VIRTUAL_ENV" ]; then
        # not in a virtualenv
        return
    fi

    echo "(`basename \"$VIRTUAL_ENV\"`)"
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
    # tmux title magic
    title "zsh - $PWD"
    duration=$(( $(date +%s) - cmd_start_time ))

    # Notify if the previous command took more than 5 seconds.
    if [ $duration -gt 5 ] ; then
      case "$lastcmd" in
        vi*) ;; # vi, don't notify
        "") ;; # no previous command, don't notify
        *)
          [ ! -z "$TMUX" ] && tmux display-message "($duration secs): $lastcmd"
      esac
    fi
    lastcmd=""
}
local git='$vcs_info_msg_0_'

# Custom status line
PS1="[`hostname | sed 's/\..*//'`] $(active_virtualenv)${git}${fg_lblue}%~ ${fg_white}$ "

# Show a green $ on the status line when vim mode is -- INSERT --
function zle-line-init zle-keymap-select {
    PS1="[`hostname | sed 's/\..*//'`] $(active_virtualenv)${git}${fg_lblue}%~ ${fg_lgreen}${${KEYMAP/vicmd/}/(main|viins)/$}${fg_white}${${KEYMAP/vicmd/$}/(main|viins)/}${fg_white} "
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# -----------------------------------------------
# Set up zsh-specifics
# -----------------------------------------------

# compinit initializes various advanced completions for zsh
fpath=($HOME/.zsh/completions $fpath)
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
    tmux attach -t term || tmux new -s term
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

source ~/.zsh/completions/pytest.plugin.zsh

function preexec() {
  # The full command line comes in as "$1"
  local cmd="$1"
  local -a args

  # add '--' in case $1 is only one word to work around a bug in ${(z)foo}
  # in zsh 4.3.9.
  tmpcmd="$1 --"
  args=${(z)tmpcmd}

  # remove the '--' we added as a bug workaround..
  # per zsh manpages, removing an element means assigning ()
  args[${#args}]=()
  if [ "${args[1]}" = "fg" ] ; then
    local jobnum="${args[2]}"
    if [ -z "$jobnum" ] ; then
      # If no jobnum specified, find the current job.
      for i in ${(k)jobtexts}; do
        [ -z "${jobstates[$i]%%*:+:*}" ] && jobnum=$i
      done
    fi
    cmd="${jobtexts[${jobnum#%}]}"
  fi

  # These are used in precmd
  cmd_start_time=$(date +%s)
  lastcmd="$cmd"

  title "$cmd"
}

function title() {
  # This is madness.
  # We replace literal '%' with '%%'
  # Also use ${(V) ...} to make nonvisible chars printable (think cat -v)
  # Replace newlines with '; '
  local value="${${${(V)1//\%/\%\%}//'\n'/; }//'\t'/ }"
  local location

  location="$HOST"
  [ "$USERNAME" != "$LOGNAME" ] && location="${USERNAME}@${location}"

  # Special format for use with print -Pn
  value="%70>...>$value%<<"
  unset PROMPT_SUBST
  case $TERM in
    screen|screen-256color)
      # Put this in your .screenrc:
      # hardstatus string "[%n] %h - %t"
      # termcapinfo xterm 'hs:ts=\E]2;:fs=\007:ds=\E]2;screen (not title yet)\007'
      print -Pn "\ek${value}\e\\"     # screen title (in windowlist)
      print -Pn "\e_${location}\e\\"  # screen location
      ;;
    xterm*)
      print -Pn "\e]0;$value\a"
      ;;
  esac
  setopt LOCAL_OPTIONS
}
