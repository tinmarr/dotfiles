#!/usr/bin/env bash

# load nvm
export NVM_DIR="$HOME/.nvm"

if [[ -e ~/.nvm/versions ]]
then 
    NODE_GLOBALS=(`find ~/.nvm/versions/node -maxdepth 3 -type l -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)
    NODE_GLOBALS+=(node nvm yarn)

    _load_nvm() {
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    }

    for cmd in "${NODE_GLOBALS[@]}"; do
	eval "function ${cmd}(){ unset -f ${NODE_GLOBALS[*]} 2> /dev/null; _load_nvm; unset -f _load_nvm; ${cmd} \$@; }"
    done

    unset cmd NODE_GLOBALS
fi

# load pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

alias pgadmin="pyenv activate pgadmin && pgadmin4"
          
# Helpful functions / Aliases
alias gitrmbranches="git branch --list| grep -v \* | xargs git branch -D"
alias pipunall="pip freeze | grep -v '^-e' | xargs pip uninstall -y"


# Better ls
alias ls="exa --icons --group-directories-first"
alias l="ls --git-ignore"
alias la="ls -a"
alias ll="ls -l --git --git-ignore"
alias lla="ls -l -a --git"

# Better cat
alias cat="bat"
export MANROFFOPT="-c" 
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Quick Emacs in Terminal
alias e="emacsclient -nw"

# Better grep
alias grep="rg"

# Ranger follow
alias lr=". ranger"

# Kitty SSH
alias s="kitten ssh"

alias updategrub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

update () {
    sudo test
    (cd ~/dotfiles && git pull && git submodule update --checkout --remote && stowall)
    curl "https://archlinux.org/mirrorlist/?country=CA&protocol=http&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on" > /tmp/mirrorlist
    sed -i 's/#//' /tmp/mirrorlist
    sudo mv /tmp/mirrorlist /etc/pacman.d/
    yay -Syyu --answerclean A --answerdiff N --removemake --noconfirm
    git -C $NVM_DIR fetch --tags origin
    git -C $NVM_DIR checkout `git -C $NVM_DIR describe --abbrev=0 --tags --match "v[0-9]*" $(git -C $NVM_DIR rev-list --tags --max-count=1)`
    if command -v rustup &> /dev/null; then
        rustup update
    fi
}

tzupdate () {
    timedatectl set-timezone $(curl https://ipapi.co/timezone)
}

# Git stuff
gitc () {
    git add .
    git commit -m $1
    git push
}

alias gits="(git fetch &>/dev/null &) && git status"
alias gitl="git log --compact-summary"

configc () {
    config commit -am $1
    config push
}

export EDITOR="emacs -nw"
export GPG_TTY=$TTY

# Path Edits
export PATH="$HOME/.amplify/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"

# Set Terminal to English
export LANG=en_US.UTF-8

export QSYS_ROOTDIR="/home/martin/.cache/yay/quartus-free/pkg/quartus-free-quartus/opt/intelFPGA/23.1/quartus/sopc_builder/bin"
