PATH=/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/usr/local/mongodb/bin:/brew/bin:/brew/sbin:/brew/share/npm/bin:$PATH

if [ -f ~/.alias ]; then
   source ~/.alias
fi

export NODE_PATH=/brew/lib/node
export EDITOR='mvim -f -c "au VimLeave * !open -a iTerm"'

# color
alias ls='ls -G'
alias vim='mvim -c "au VimLeave * !open -a iTerm"'

export GREP_COLOR=32
alias grep='grep --color'

# colored git branch/status for my prompt
parse_git_branch (){
  gitver=$(git branch --no-color 2>/dev/null| sed -n '/^\*/s/^\* //p')
  if [ -n "$gitver" ]
  then
    echo -e "("$gitver")"
  fi
}
PS1="\[\033[35m\]\$(parse_git_branch)\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "

alias ..="cd .."

# I wish py.test did this by default...
alias py.test="py.test --tb=short"

alias drc='cd ~/Development/draughtcraft && source ../dcenv/bin/activate'
