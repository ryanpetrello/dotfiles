export TERM='screen-256color'
# colors
export CLICOLOR=1
export LSCOLORS=DxDxCxDxexexexaxaxaxax
export GREP_COLOR=32

# Auto-attach to mutt tmux
if [ -z "$TMUX" ]; then
    # not in a tmux session
    tmux attach -t mutt -d || tmux new -s mutt
fi

# Always open mutt in ~/Desktop so that downloaded mail attachments save there
alias mutt='cd ~/Desktop && /usr/local/bin/mutt'
