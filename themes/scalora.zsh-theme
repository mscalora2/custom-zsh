#! /usr/bin/env zsh
# to help editors with syntax coloring etc.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# theme autoloads

autoload colors
autoload -U add-zsh-hook
autoload -Uz vcs_info

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# theme options

PR_GIT_UPDATE=1
setopt prompt_subst

setopt histignorespace

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# theme aliases

function hist {
  CI=""
  if [[ "$1" == "--help" || "$1" == "-h" || "$1" == "-?" ]] ; then
    echo "Usage:"
    echo "    $0 [ -i ] <number>       - show last <number> items"
    echo "    $0 [ -i ] <regexp>       - search history for <regexp>"
    echo "    $0 [ -i ] <regexp> <number>  - show last <number> items that match <regexp>"
    echo "    $0 [ -i ] <number> <regexp>  - search last <number> items for <regexp>"
    echo "    $0 [ -i ] <regexp1> <regexp2>  - search history for <regexp1> AND <regexp2>"
    echo "    $0 <number1> <number2>     - show <number2> items starting at <number1>"
    echo ""
    echo "  Options:"
    echo "    -i         - use case insensitive search for regexp"
    echo "    --help -h or -?  - show this help"
    echo ""
  else
    if [[ "$1" == "-i" ]] then
      CI="-i"
      shift
    fi
    if [[ "$1" == "" ]] ; then
      echo "Last 50 history items"
      history | tail -n 50
    elif [[ $1 =~ [0-9]+ ]] ; then
      if [[ "$2" == "" ]] ; then
        echo "Last $1 history items"
        history | tail -n $1
      elif [[ "$2" =~ [0-9]+ ]] ; then
        echo "History items $1 through $(( $1 + $2 ))"
        history | head -n $(( $1 + $2 )) | tail -n $2
      else
        echo "Last $1 history items that also match $2"
        history | tail -n $1 | egrep $CI $2
      fi
    else
      if [[ "$2" == "" ]] ; then
        echo "History items that match $1"
        history | egrep $CI $1
      elif [[ "$2" =~ [0-9]+ ]] ; then
        echo "Last $2 matches of $1 in history"
        history | egrep $CI $1 | tail -n $2
      else
        echo "History items that match $1 and $2"
        history | egrep $CI $1 | egrep $CI $2
      fi
    fi
  fi
}

# platform specific aliases

if [ "$(uname)" = "Darwin" ] ; then
  # Mac only aliases
  alias usb="ioreg -p IOUSB"
else
  # Linux only aliases
  alias usb=lsusb
fi

autoload -Uz modify-current-argument

function toggle-path-py {
  REPLY="$(python - $1 <<EOF
"Toggle between relative and absolute path, surrounding quotes or initial quote"
import os, sys
a = sys.argv[1]
f = a[:1]
e = ''
if f == '~':
  a = os.path.expanduser(a)
  f = ''
elif f == '"' or f == "'":
  a = a[1:]
  if a[-1:] == f:
    e = f
    a = a[:-1]
else:
  f = ''
b = os.path.relpath(a) if a[:1] == '/' else os.path.abspath(a)
sys.stdout.write(f+b+e)
EOF
)"
}

function toggle-path {
  modify-current-argument toggle-path-py
}

zle -N toggle-path
bindkey "å" toggle-path
bindkey "\ea" toggle-path

swap-quotes() {
  BUFFER="$( echo -n "$BUFFER" | tr "\"'" "'\"")"
}

zle -N swap-quotes
bindkey "ß" swap-quotes

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# smart alias type functions

export NATIVE_CODE="$(which code)"

code() {
  if [ $REMOTE_SESSION == 1 ] ; then
    ${EDITOR:?nano} $*
  elif [ -x "$NATIVE_CODE" ] ; then
    "$NATIVE_CODE" $*
  elif [ -d "/Applications/Visual Studio Code.app" ] ; then
    open -a "/Applications/Visual Studio Code.app" $*
  elif [ -d "/Applications/Code.app" ] ; then
    open -a "/Applications/Code.app" $*
  else
    open "https://code.visualstudio.com/download"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# local system setup

setup_nano() {
  echo "# AUTO CREATED NANORC FILE" >>~/.nanorc
  echo "set quiet" >>~/.nanorc
  echo "set autoindent" >>~/.nanorc
  echo "set constantshow" >>~/.nanorc
  echo "set positionlog" >>~/.nanorc
  echo "set tabsize 4" >>~/.nanorc
  echo "set tabstospaces" >>~/.nanorc
  echo "set nowrap" >>~/.nanorc
  echo "set suspend" >>~/.nanorc
  echo "set titlecolor brightyellow,blue" >>~/.nanorc
  echo "set statuscolor brightyellow,blue" >>~/.nanorc
  echo "bind ^S savefile main" >>~/.nanorc
  echo "bind ^G findnext main" >>~/.nanorc
  echo "bind M-G findprevious main" >>~/.nanorc
  if [ ! -d $HOME/temp/nano-backups ] ; then
    mkdir $HOME/temp/nano-backups
  fi
  echo "set backupdir $HOME/temp/nano-backups" >>~/.nanorc
  # try to find the best path to nanorc syntax file files
  find -L /usr/local/share -mount \! -perm -g+r,u+r,o+r -prune -o -name css.nanorc -print | head -n 1 | sed -e 's/css/*/' | sed -e 's/^/include /' >>~/.nanorc

  echo "=================================================="
  echo "A nice .nanorc file was created for you, it won't"
  echo "have any affect unless you run nano. You can turn"
  echo "off all of the affects of this change by running:"
  echo "echo \"#\" >~/.nanorc"
  echo "=================================================="
}

[ ! -f ~/.nanorc ] && setup_nano
unset -f setup_nano

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# custom keys

bindkey "\x1b\x1b\x5b\x41" beginning-of-line  # option up for iTerm
bindkey "\x1b\x1b\x5b\x42" end-of-line        # option down for iTerm
bindkey "\x1b\x1b\x5b\x43" forward-word       # option right for iTerm
bindkey "\x1b\x1b\x5b\x44" backward-word      # option left for iTerm

bindkey "^[[:u" undo
bindkey "^[[:r" redo

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# for extra completions, any .inc file in plugins is included

for inc in $ZSH_CUSTOM/plugins/*.inc(.N) ; do 
  source $inc
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# self-update

ts_file=~/.zsh-custom-update

upgrade_custom() {
  printf '\033[0;34m%s\033[0m\n' "Upgrading the custom files"
  pushd "$ZSH_CUSTOM" >/dev/null
  if git pull --rebase --stat origin master
  then
    printf '\033[0;32m%s\033[0m\n' '                _                  '
    printf '\033[0;32m%s\033[0m\n' '  ___  ___ __ _| | ___  _ __ __ _  '
    printf '\033[0;32m%s\033[0m\n' ' / __|/ __/ _` | |/ _ \| |__/ _` | '
    printf '\033[0;32m%s\033[0m\n' ' \__ \ ❨_| ❨_| | | ❨_❩ | | | ❨_| | '
    printf '\033[0;32m%s\033[0m\n' ' |___/\___\__,_|_|\___/|_|  \__,_| '
    printf '\033[0;32m%s\033[0m\n' '                                   '
    printf '\033[0;34m%s\033[0m\n' 'Hooray! The custom files have been updated and/or are at the current version.'
  else
    printf '\033[0;31m%s\033[0m\n' 'There was an error updating. Try again later? You can trigger an update with: upgrade_custom'
  fi
  popd >/dev/null
}

upgrade_custom_update() {
  echo -n "$1" >! $ts_file
}

upgrade_custom_check() {
  local ts
  local prev='missing-ts'
  if [[ -f $ZSH/.git/FETCH_HEAD ]] ; then
    if [[ "$OSTYPE" == darwin* ]]; then
      ts=$(stat -f '%Sm' $ZSH/.git/FETCH_HEAD || echo 'missing' )
    else
      ts=$(stat -c %y $ZSH/.git/FETCH_HEAD || echo 'missing' )
    fi

    if [[ -f $ts_file ]] ; then
      prev=$(cat $ts_file)
    fi

    if [[ $ts != $prev ]] ; then
      upgrade_custom_update "$ts"
      upgrade_custom    
    fi
  fi
}

upgrade_custom_check

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# theme color vars

colors

#use extended color pallete if available
if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
    turquoise="%F{81}"
    orange="%F{166}"
    purple="%F{135}"
    hotpink="%F{161}"
    limegreen="%F{118}"
else
    turquoise="$fg[cyan]"
    orange="$fg[yellow]"
    purple="$fg[magenta]"
    hotpink="$fg[red]"
    limegreen="$fg[green]"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# style section

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*:prompt:*' check-for-changes true

PR_RST="%{${reset_color}%}"
FMT_BRANCH="(%{$turquoise%}%b%u%c${PR_RST})"
FMT_ACTION="(%{$limegreen%}%a${PR_RST})"
FMT_UNSTAGED="%{$orange%}●"
FMT_STAGED="%{$limegreen%}●"

zstyle ':vcs_info:*:prompt:*' unstagedstr   "${FMT_UNSTAGED}"
zstyle ':vcs_info:*:prompt:*' stagedstr     "${FMT_STAGED}"
zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
zstyle ':vcs_info:*:prompt:*' nvcsformats   ""

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# custom hooks

function z_custom_preexec {
    case "$(history $HISTCMD)" in
        *git*)
            PR_GIT_UPDATE=1
            ;;
        *svn*)
            PR_GIT_UPDATE=1
            ;;
    esac
}
add-zsh-hook preexec z_custom_preexec

function z_custom_chpwd {
    PR_GIT_UPDATE=1
}
add-zsh-hook chpwd z_custom_chpwd

function z_custom_precmd {
    if [[ -n "$PR_GIT_UPDATE" ]] ; then
        # check for untracked files or updated submodules, since vcs_info doesn't
        if git ls-files --other --exclude-standard 2> /dev/null | grep -q "."; then
            PR_GIT_UPDATE=1
            FMT_BRANCH="(%{$turquoise%}%b%u%c%{$hotpink%}●${PR_RST})"
        else
            FMT_BRANCH="(%{$turquoise%}%b%u%c${PR_RST})"
        fi
        zstyle ':vcs_info:*:prompt:*' formats "${FMT_BRANCH} "

        vcs_info 'prompt'
        PR_GIT_UPDATE=
    fi
}
add-zsh-hook precmd z_custom_precmd

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# virtual environment info

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('$fg[blue]`basename $VIRTUAL_ENV`%{$reset_color%}') '
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# detect remote connections

# detect if this is a remote connection
export REMOTE_SESSION=0
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ $PPID -eq 0 ]; then
  export REMOTE_SESSION=1
else
  case $(ps -o comm= -p $PPID) in
    sshd|*/sshd) 
      export REMOTE_SESSION=1
    ;;
  esac
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# host colors

local_color=${ZLOCALCOLOR:-$orange}
remote_color=${ZREMOTECOLOR:-$bg[green]$fg[black]}
[[ $REMOTE_SESSION = 1 ]] && PAD=" " || PAD=""
[[ $REMOTE_SESSION = 1 ]] && ZHOST_COLOR="$remote_color" || ZHOST_COLOR="$local_color"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# override system names

OVERRIDE_SYSNAME=${PROMPT_SYS_NAME:-$ZSYSNAME}
ZSYSNAME=${OVERRIDE_SYSNAME:-$(echo $(hostname) | cut -d "." -f1)}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# final prompt

PROMPT=$'
%{$purple%}%n%{$reset_color%} on %{$ZHOST_COLOR%}%{$PAD%}$ZSYSNAME%{$PAD%}%{$reset_color%} at %{$turquoise%}%T%{$reset_color%} in %{$limegreen%}%~%{$reset_color%} $vcs_info_msg_0_$(virtualenv_info)%{$reset_color%}
${ZPTAIL-$ }'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# final return status prompt

# R=$fg[red]
# G=$fg[green]
# M=$fg[magenta]
# RB=$fg_bold[red]
# YB=$fg_bold[yellow]
# BB=$fg_bold[blue]
# RESET=$reset_color

export RPS1="%(?..%{$fg_bold[yellow]%}%? ↵%{$reset_color%})"


