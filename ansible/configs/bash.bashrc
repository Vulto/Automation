# Only run for UID 1000 (replace with your UID) in an interactive TTY session
if [[ "$UID" -eq 1000 && -t 0 && -z "$SX_RUNNING" ]]; then
    # Mark that sx is about to run to prevent loops
    export SX_RUNNING=1

    # Start sx to launch dwm
    sx

    # After sx exits (dwm and Xorg are done), logout
    if [ -n "$BASH" ] && [ "$SHLVL" -eq 1 ]; then
        logout  # For login shells
    else
        exit    # For non-login shells
    fi
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

RED="\[\033[01;31m\]"
GREEN="\[\033[01;32m\]"
CLEAR="\[\033[00m\]"
[[ $UID = 1000 ]] && PS1="\n $GREEN \h $CLEAR \w  \n      → " || PS1="\n \e[1;31m # [ \h - \w ] \e[m \n    "

export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoredups:erasedups

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
	function command_not_found_handle {
	        # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
		   /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
		else
		   printf "%s: command not found\n" "$1" >&2
		   return 127
		fi
	}
fi

# Quick navigation
cdf() {
    local dir
    dir=$(locate -e -r /home/$USER \| /var \| /etc | fzf --preview 'ls -l {} 2>/dev/null')
    if [[ -n "$dir" && -d "$dir" && -x "$dir" ]]; then
        builtin cd "$dir"
        [[ $UID = 1000 ]] && PS1="\n  \w  \n   → " || PS1="\n \e[1;31m # [ \w ] \e[m \n    "
    elif [[ -n "$dir" ]]; then
        echo "Error: Cannot access '$dir'."
    fi
}

lf() {
	if [[ $UID = 0 ]]; then
		# 2 versions of the same command because  why not ?
    #locate -r '' | fzf --preview='cat {}' --bind "enter:execute(nopen {})+abort"
    find / -type f  | fzf --preview='cat {}' --bind "enter:execute(nopen {})+abort"
	else
		fzf --preview='cat {}' --bind 'enter:execute(nopen {1})+abort'
	fi
}

apts() {
 apt-cache search . | awk '{print $1}' | fzf --preview 'apt-cache show {1}' --bind 'enter:execute(sudo apt install {1} -y)+abort'
}

# Aliases
alias ls="ls --color=auto -1"
alias l="ls -1"
alias ll="ls -lhr"
alias la="ls -lhra"
alias bc="bc -q"
alias rm="rm -iv"
alias mv="mv -vni"
alias q="exit"
alias less="less -R"
alias df="df -h"
alias du="du -sh"
alias ..="cd .."
alias ...="cd ../.."
alias ip='ip -c'

# \C-? < control+some character
# \e? < Alt+some character
# \ew? < Alt+Shift+some character

bind '"\ed":"cdf\n"'
bind '"\ef":"lf\n"'
