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
 
# prompt customization
CLR_GRAY="\001\e[0;90m\002"
CLR_RED="\001\e[0;91m\002"
CLR_GREEN="\001\e[0;92m\002"
CLR_YELLOW="\001\e[0;93m\002"
CLR_BLUE="\001\e[0;94m\002"
CLR_PURPLE="\001\e[0;95m\002"
CLR_CYAN="\001\e[0;96m\002"
CLR_WHITE="\001\e[0;97m\002"
 
CLR_RESET="\001\e[0m\002"
 
function onPrompt()
{
    prompt_storeResult
    prompt_calculateElapsedTime
    if [[ $(prompt_useColors) == true ]]; then
        prompt_setDetailedPrompt
        # prompt_setSimplifiedPrompt
        # prompt_setBasicPrompt
    else
        prompt_setBasicPrompt
    fi
 
}
 
function prompt_storeResult()
{
    prompt_previousResult=$?
}
 
function prompt_storeStartTime()
{
    [[ $prompt_startTime ]] || prompt_startTime=$SECONDS
}
 
function prompt_calculateElapsedTime()
{
    if [[ $prompt_startTime ]]; then
        prompt_elapsedTime=$((SECONDS - prompt_startTime))
        unset prompt_startTime
    else
        prompt_elapsedTime=0
    fi
}
 
function prompt_printElapsedTime()
{
    if [[ $prompt_elapsedTime -ge 0 ]]; then
        if [[ $prompt_elapsedTime -lt 60 ]]; then
            echo -n "$(date --utc --date=@$prompt_elapsedTime +'%ss')"
        elif [[ $prompt_elapsedTime -lt 3600 ]]; then
            echo -n "$(date --utc --date=@$prompt_elapsedTime +'%-Mm %-Ss')"
        elif [[ $prompt_elapsedTime -lt 86400 ]]; then
            echo -n "$(date --utc --date=@$prompt_elapsedTime +'%-Hh %-Mm %-Ss')"
        else
            echo -n "$(date --utc --date=@$prompt_elapsedTime +'%ss')"
        fi
    else
        echo -n "--"
    fi
}
 
function prompt_useColors()
{
    local force_color_prompt=true
    local color_prompt=false
 
    # set a fancy prompt (non-color, unless we know we "want" color)
    case "$TERM" in
    xterm-color | *-256color) color_prompt=true ;;
    esac
 
    if [[ "$force_color_prompt" == true ]]; then
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
            # We have color support; assume it's compliant with Ecma-48
            # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
            # a case would tend to support setf rather than setaf.)
            color_prompt=true
        else
            color_prompt=false
        fi
    fi
 
    echo $color_prompt
}
 
function prompt_printHost()
{
    local host=$(uname -n)
    echo -n "${host%%.*}"
}
 
function prompt_printCurrentDir()
{
    if [[ $PWD == $HOME* ]]; then
        echo -n "~${PWD#$HOME}"
    else
        echo -n "$PWD"
    fi
}
 
function prompt_printRightAlignedInfo()
{
    local text=""
    # if [[ -n $BUILD ]]; then
    #     text+=" BUILD=${BUILD}"
    # fi
    # text+=", KERNEL=$(uname -r)"
    text+=" $(date +'%H:%M:%S')"

    local term_width=$(tput cols)
    printf '%*s\r' $term_width "${text}"
}
 
function prompt_printGitDetails()
{
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    __git_ps1 | sed -r "s@ \((\S+)(( )(\*)?(\+)?(%)?)?( (.*))?\)@\1 \\\001\\\e[0m\\\002\4\5\6[\8]@g;s@\[\]@@g"
}
 
function prompt_printVirtualEnv()
{
    if [[ -n $VIRTUAL_ENV ]]; then
        echo -n "($(basename $VIRTUAL_ENV)) "
    fi
}
 
function prompt_printUserSymbol()
{
    if [[ "$(whoami)" == "root" ]]; then
        echo -n "#"
    else
        echo -n "$"
    fi
}
 
function prompt_setDetailedPrompt()
{
    export PS1
 
    PS1="${CLR_GRAY}$(prompt_printRightAlignedInfo)${CLR_RESET}┌"
    [[ $prompt_previousResult == 0 ]] && PS1+="" || PS1+="${CLR_RED}"
    PS1+=" $(prompt_printElapsedTime) "
 
    PS1+="\n${CLR_RESET}│ "
    PS1+="${CLR_GREEN}$(whoami)"
    PS1+="${CLR_WHITE} at "
    PS1+="${CLR_YELLOW}$(prompt_printHost)"
    PS1+="${CLR_WHITE} in "
    PS1+="${CLR_BLUE}$(prompt_printCurrentDir)"
    if git rev-parse --is-inside-git-dir &> /dev/null; then
        PS1+="${CLR_WHITE} on "
        PS1+="${CLR_PURPLE}$(prompt_printGitDetails)"
    fi
    if [[ -f /.dockerenv || -f /run/.containerenv ]]; then
        PS1+="${CLR_YELLOW} "
    fi
    PS1+="${CLR_RESET}\001\e[K\002\n└─── $(prompt_printVirtualEnv)$(prompt_printUserSymbol) "
}
 
function prompt_setSimplifiedPrompt()
{
    export PS1
 
    PS1="${CLR_RESET}"
    PS1+="${CLR_GREEN}$(whoami)"
    PS1+="${CLR_WHITE} at "
    PS1+="${CLR_YELLOW}$(prompt_printHost)"
    PS1+="${CLR_WHITE} in "
    PS1+="${CLR_BLUE}$(prompt_printCurrentDir)"
    if git rev-parse --is-inside-git-dir &> /dev/null; then
        PS1+="${CLR_WHITE} on "
        PS1+="${CLR_PURPLE}$(prompt_printGitDetails)"
    fi
    PS1+="${CLR_RESET}\001\e[K\002\n└── $(prompt_printVirtualEnv)$(prompt_printUserSymbol) "
}
 
function prompt_setBasicPrompt()
{
    export PS1
    PS1="\u@\h: \w\a \$ "
}
 
export PROMPT_COMMAND="onPrompt"
trap prompt_storeStartTime DEBUG
 
# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac
 
# enable color support of common utilities
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
 
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
 
# others
alias rebash='source ~/.bashrc'
 
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
