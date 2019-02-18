#!/bin/bash.exe

unset MAILCHECK
ulimit -c 0

HISTCONTROL=ignoredups
HISTFILE=/home/mobaxterm/.bash_history
HISTSIZE=16000
TMOUT=0
export HISTCONTROL HISTFILE HISTSIZE TMOUT
shopt -s nocaseglob
shopt -s checkwinsize
shopt -s dotglob

# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Make bash file completion case insensitive
shopt -s nocaseglob

# Set command line editing mode to emacs
set -o vi

# Set default file creation permissions
umask 0002

# Prompt colors
C1="\[\033[0;30m\]" # Black
C2="\[\033[1;30m\]" # Dark Gray
C3="\[\033[0;31m\]" # Red
C4="\[\033[1;31m\]" # Light Red
C5="\[\033[0;32m\]" # Green
C6="\[\033[1;32m\]" # Light Green
C7="\[\033[0;33m\]" # Brown
C8="\[\033[1;33m\]" # Yellow
C9="\[\033[0;34m\]" # Blue
C10="\[\033[1;34m\]" # Light Blue
C11="\[\033[0;35m\]" # Purple
C12="\[\033[1;35m\]" # Light Purple
C13="\[\033[0;36m\]" # Cyan
C14="\[\033[1;36m\]" # Light
C15="\[\033[0;37m\]" # Light Gray
C16="\[\033[1;37m\]" # White
P="\[\033[0m\]" # Neutral

# Set the terminal up so tmux can use 256 color solarized color scheme
#export TERM="screen-256color"
#export TERM="xterm-256color"
#export TERM="screen"
#export TERM="xterm"
#alias tmux="tmux -2"

# Prompt
[[ -z "$SSH_CLIENT" ]] && PROMPT_COLOR=$C6 || PROMPT_COLOR=$C3
if [ -e ~/.git-prompt.sh ]; then
    . ~/.git-prompt.sh
    export PS1="$P$PROMPT_COLOR\u@\h $C10:\w$P$C8\$(__git_ps1)
$C16$ "
else
    export PS1="$P$PROMPT_COLOR\u@\h $C10:\w$P$C8
$C16$ "
fi

# Git autocomplete
if [ -e ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi

# Environment variables
export EDITOR="vim"

# Kill the VIM environment variable created by Winblows
export VIM=

# Aliases
alias ls='ls -p -A --color'
alias vi='vim'
alias gitlog='git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
alias get='git '
alias logout='gnome-session-quit'
alias v='vagrant'

export PATH=$PATH:$HOME/bin:/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:.

export GIT_PAGER='less -FRXK'
# added by Anaconda3 5.3.0 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '/home/dheater/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/home/dheater/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/dheater/anaconda3/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/home/dheater/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<

# Golang stuff
export GOPATH=$(go env GOPATH)
export PATH=$PATH:GOPATH/bin
