PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/usr/local/mongodb/bin:/brew/bin:/brew/sbin:/brew/share/npm/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH
export NODE_PATH=/brew/lib/node
export PYTHONPATH=$PYTHONPATH:$HOME/site
export PYTHONSTARTUP=$HOME/.pythonrc

# zsh vim mode
set -o vi

# vim text object support
#source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

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
alias idk="printf \"¯\_(ツ)_/¯\" | pbcopy && echo '¯\_(ツ)_/¯'"
alias vi="vim"
alias ack="rg"

export LESS=FRSXQ

# Always open mutt in ~/Desktop so that downloaded mail attachments save there
function mutt() {
    cd ~/Desktop && /usr/local/bin/mutt "$@"
}

# CLI for 1Password.  Requires the `1pass` Python package
function 1pass() { sudo -u $(whoami) /usr/bin/security find-generic-password -l 1pass -w | $WORKON_HOME/1pass/bin/1pass --no-prompt --fuzzy "$@" | tr -d '\012\015' | pbcopy }
alias 1p='1pass'

function branch() {
    git symbolic-ref --short HEAD
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

function gh() {
    if [ "$#" -eq 1 ]; then
        echo "git@github.com:ryanpetrello/$1.git"
    fi
    if [ "$#" -eq 2 ]; then
        echo "git@github.com:$1/$2.git"
    fi
}


# ack-specific settings
export ACK_COLOR_MATCH='red'

# virtualenvwrapper settings
export WORKON_HOME=~/venvs
VIRTUALENVWRAPPER=/usr/local/bin/virtualenvwrapper.sh
if [[ -f $VIRTUALENVWRAPPER ]]; then
    function workon() {
        unfunction "$0"
        source $VIRTUALENVWRAPPER
        $0 "$@"
    }
    function mkvirtualenv () {
        unfunction "$0"
        source $VIRTUALENVWRAPPER
        $0 "$@"
    }
    function mktmpenv () {
        unfunction "$0"
        source $VIRTUALENVWRAPPER
        $0 "$@"
    }
fi

# history
HISTFILE=$HOME/.zsh_history
HISTSIZE=999999999
SAVEHIST=999999999
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt hist_ignore_all_dups
bindkey '^R' history-incremental-search-backward
h() { if [ -z "$*" ]; then history 1; else history 1 | egrep "$@"; fi; }

# vim as default + launch settings
export EDITOR='vim'
export TERM='xterm-256color'

# colors
export CLICOLOR=1
export LSCOLORS=DxDxCxDxexexexaxaxaxax
export GREP_COLOR=32
alias grep='grep --color'
function speedtest() {
    echo "`curl  --progress-bar -w "%{speed_download}" http://speedtest.wdc01.softlayer.com/downloads/test100.zip -o /dev/null` / 131072" | bc | xargs -I {} echo {} mbps
}
function jgrep() {
    NEEDLE=`echo $@ | sed "s/ /\|/g"`
    cat | egrep -oh "\"($NEEDLE)\":\s?\"[^\"]*\"" | egrep --color $NEEDLE
}
function haystack() {
  # call vim on a file (or glob) to perform a search and replace operation
  # with confirmation. Does not save automagically. Example usage:
  #     vsed foo bar *.py
  # Will search for 'foo' and replace it with 'bar' in all matching *.py files.
  # It also supports globbing for recursive files:
  #     vsed foo bar **/*.py
  search=$1
  replace=$2
  shift
  shift
  vim -c "bufdo! set eventignore-=Syntax| %s/$search/$replace/gce | update" $*

}

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
    psvar[5]=''
    ifconfig | grep -q utun
    if [ $? -eq 0 ]; then
        psvar[5]=$(ps -ef | grep -q openvpn && echo " 🔒 ")
    fi
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        zstyle ':vcs_info:*' formats $'[%{\e[1;33m%}%b%F{foreground}:%c%u%F{foreground}] '
    } else {
        zstyle ':vcs_info:*' formats $'(%{\e[1;33m%}%b%F{foreground}:%c%u%F{white}●%F{foreground}) '
    }
    vcs_info
}
local git='$vcs_info_msg_0_'

# Custom status line
PS1="[`hostname | sed 's/\..*//'`]${fg_lblue}%5v${fg_white} ${git}${fg_lblue}%~ ${fg_white}"

# Show a different cursor for different vim modes
function zle-keymap-select zle-line-init
{
    case $KEYMAP in
        vicmd)      print -n -- "\E]50;CursorShape=0\C-G";;  # block cursor
        viins|main) print -n -- "\E]50;CursorShape=1\C-G";;  # line cursor
    esac

    zle reset-prompt
    zle -R
}

function zle-line-finish
{
    print -n -- "\E]50;CursorShape=0\C-G"
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

# # 10ms for key sequences
KEYTIMEOUT=1

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

# Cache completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $HOME/.zsh/cache

setopt auto_menu         # show completion menu on succesive tab press
setopt complete_in_word
setopt always_to_end
setopt  globcomplete
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 2 numeric
zstyle -e ':completion:*:approximate:*'  max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# Partial color matching on TAB
highlights='${PREFIX:+=(#bi)($PREFIX:t)(?)*==$color[blue]=00}':${(s.:.)LS_COLORS}}
zstyle -e ':completion:*' list-colors 'reply=( "'$highlights'" )'
zstyle -e ':completion:*:-command-:*:commands' list-colors 'reply=(
"'$highlights'" )'
unset highlights

source ~/.zsh/completions/pytest.plugin.zsh

# bind UP and DOWN arrow keys (compatibility fallback
# # for Ubuntu 12.04, Fedora 21, and MacOSX 10.9 users)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# The next line updates PATH for the Google Cloud SDK.
if [ -f ~/google-cloud-sdk/path.zsh.inc ]; then
  source ~/google-cloud-sdk/path.zsh.inc
fi

# The next line enables shell command completion for gcloud.
if [ -f ~/google-cloud-sdk/completion.zsh.inc ]; then
  source ~/google-cloud-sdk/completion.zsh.inc
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

export NVM_DIR="$HOME/.nvm"
function nvm() {
    unfunction "$0"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion<Paste>
    $0 "$@"
}
export GPG_TTY=$(tty)
