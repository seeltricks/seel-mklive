#!/bin/bash
# ~/.bashrc
# shellcheck disable=SC2034,SC1090,SC1094

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# Check window size after each command, and if necessary
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# If there are multiple matches for completion, Tab should cycle through them
bind 'TAB':menu-complete

# Colour autocomplete suggestions
bind "set colored-stats on"

# Use up and down arrows to search command history
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# ===============
# HISTORY CONTROL
# ===============

shopt -s histappend

# Don't save duplicates
HISTCONTROL=ignoreboth:erasedups

# Append to the history file immediately with history -a
# Clear the current history in the shell session with history -c
# Reload the updated history back into the shell session with -r command
export PROMPT_COMMAND="history -a; history -c; history -r $PROMPT_COMMAND"

# If bpytop is installed then alias top to bpytop 
[ -e /usr/bin/btop ] && alias top="/usr/bin/btop"
alias ls='ls --color=auto -hv --group-directories-first'
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Only use aliases according to the TERM we are in
case $TERM in
  xterm*|konsole*|foot*)
     alias vim='nvim';;
  linux)
    alias vim="nvim";;
  *)
esac

command -v bat > /dev/null && alias cat='bat --paging=never'
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

# alias to stop foot terminal confusing ssh
if [[ $TERM = "foot" ]]; then
  alias ssh='TERM=linux ssh'
fi

export EDITOR="nvim"
export VISUAL="nvim"
export MANPATH=$HOME/.local/share/man/:$MANPATH
export PATH=$PATH:~/.local/bin
export BROWSER="firefox"
export XDG_CONFIG_HOME="$HOME/.config"
export MOZ_ENABLE_WAYLAND=1
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
# export QT_QPA_PLATFORM=wayland
export XKB_DEFAULT_LAYOUT=us
#export LANG="en_US.UTF-8"
#export LC_ALL="en_US.UTF-8"
export SSH_ASKPASS=~/.local/bin/ssh-askpass
export TERMINAL="foot"
export SAL_USE_VCLPLUGIN=gtk3

# Enable the use of ssh-agent
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

# If on matching tty start the WM 
if [ "$(tty)" = "/dev/tty1" ]; then
	exec dbus-run-session qtile start -b wayland
fi
