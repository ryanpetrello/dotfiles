PATH=/usr/local/mysql/bin:/usr/local/mongodb/bin:/brew/bin:/brew/sbin:/brew/share/npm/bin:$PATH

if [ -f ~/.shootq ]; then
   source ~/.shootq
fi

export NODE_PATH=/brew/lib/node
export EDITOR='mvim -f -c "au VimLeave * !open -a iTerm"'

# color
alias ls='ls -G'
alias vim='mvim -c "au VimLeave * !open -a iTerm"'

export GREP_COLOR=32
alias grep='grep --color'

PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "

alias ..="cd .."

set background=dark

# I wish py.test did this by default...
alias py.test="py.test --tb=short"
