###########################################################
#                                                         #
#   This is a personal .bashrc file of Michal Rutkowski   #
#                                                         #
###########################################################

# source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# if not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# colors
black='\e[0;30m'
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
blue='\e[0;34m'
magenta='\e[0;35m'
cyan='\e[0;36m'
light_gray='\e[0;37m'
dark_gray='\e[0;90m'
bright_red='\e[0;91m'
bright_green='\e[0;92m'
bright_yellow='\e[0;93m'
bright_blue='\e[0;94m'
bright_magenta='\e[0;95m'
bright_cyan='\e[0;96m'
white='\e[0;97m'

on_black='\e[40m'
on_red='\e[41m'
on_green='\e[42m'
on_yellow='\e[43m'
on_blue='\e[44m'
on_purple='\e[45m'
on_cyan='\e[46m'
on_white='\e[47m'

# color reset
NC="\e[m"

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# checking if you are a root user
if [[ "$(whoami)" == "root" ]]; then
    user_color=${bright_red}
    user_symbol="#"
else
    user_color=${bright_green}
    user_symbol="$"
fi

# prompt customization
git_info() {
    branch_name=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [[ -z "$branch_name" ]]; then
        return
    fi
    echo -e "on ${bright_magenta}${branch_name}${NC}"
}

if [ "$color_prompt" = yes ]; then
    prefix="${debian_chroot:+($debian_chroot)}"
    user="\[${user_color}\]\u\[${NC}\]"
    host="\[${bright_yellow}\]\h\[${NC}\]"
    dir="\[${bright_blue}\]\w\[${NC}\]"
    prompt="\n\[${user_color}\]└── ${NC}\]${user_symbol} "
    lhs="${prefix}${user} at ${host} in ${dir} \$(git_info) ${prompt}"

    current_time="\$(date +%H:%M:%S)"
    command_syntax_correction=9
    rhs="\[${white}\]${current_time}\[${NC}\]"
    rhs_stripped=$(sed "s/\\\[\\\e\[[0-9;]*[a-zA-Z]\\\]//g" <<<"$rhs")
    rhs_position=$((${COLUMNS} - ${#rhs_stripped} + ${#rhs} + command_syntax_correction))

    PS1="$(printf "%${rhs_position}s\r%s" "$rhs" "$lhs")"
else
    PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w${user_symbol} "
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

fi

# shortcuts
alias sl='ls'
alias qq='exit'
alias cc='clear'
alias hh='history'
alias jj='jobs -l'

# directories
alias home='cd ~'
alias root='cd /'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# If '~/.bash_aliases' exists, all aliases above would be overwritten
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
