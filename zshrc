#export HOMEBREW_TEMP=~/reno/tmp
#export PATH=$PATH:~/reno/homebrew/bin

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-15.jdk/Contents/Home

# Make globbing case insenstive
setopt NO_CASE_GLOB
# and make it work like bash
setopt GLOB_COMPLETE

# If I type a directory name without `cd ` pretend I said `cd `
setopt AUTO_CD

SAVEHIST=5000
HISTSIZE=2000
# store times in history
setopt EXTENDED_HISTORY
# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY
# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY
# expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST 
# do not store duplications
setopt HIST_IGNORE_DUPS
#ignore duplicates when searching
setopt HIST_FIND_NO_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS
# verify we are substituting the command we expect on ! (bang)
setopt HIST_VERIFY

# Fix my typos
setopt CORRECT
setopt CORRECT_ALL

# Aliases
alias ls='ls -p -A -G'

# Prompt
PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~@%m%b %(!.#.$)%f '

# Git prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git
