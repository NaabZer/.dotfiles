#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '


# Aliases
declare -a ALIAS_PATHS=("/home/naabzer/aliases/*" "/home/naabzer/develop/liu/aps/aliases/*")


for path in "${ALIAS_PATHS[@]}"; do
    for f in $path; do
        . "$f"
    done
done

export PATH="$PATH:$(ruby -e 'print Gem.user_dir')/bin"

# Make ctrl+shift+t open terminals in pwd
. /etc/profile.d/vte.sh

export TERMINAL=alacritty

function fcd {
  cd $(find . \( \
    -name ".git" -o \
    -name ".dotnet" -o \
    -name "debug" -o \
    -name "bin" -o \
    -name "env" -o \
    -name "venv" -o \
    -name "obj" -o \
    -name ".idea" -o \
    -name ".fleet" -o \
    -name "node_modules" -o \
    -name "volumes" -o \
    -name ".terraform" -o \
    -name "Library" -o \
    -name "Pictures" -o \
    -name "Documents" -o \
    -name ".local" -o \
    -name ".nuget" -o \
    -name ".npm" -o \
    -name ".vscode" -o \
    -name ".rustup" -o \
    -name ".cargo" -o \
    -name ".quokka" -o \
    -name ".vscode-insiders" \
  \) -prune -false -o -type d -print | fzf)
}

alias tlmgr='/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode'

# Add android SDK support for React Native
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

#Android 
export ANDROID_HOME=/home/naabzer/Android/Sdk 

export NODE_PATH=$NODE_PATH:`npm root -g`

# Tizen studio
export PATH="$PATH:~/tizen-studio/tools/ide/bin/"

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        source "$BASE16_SHELL/profile_helper.sh"

#fucking matlab
export LD_LIBRARY_PATH="/usr/local/MATLAB/R2024b/bin/glnxa64"
eval "$(direnv hook bash)"
