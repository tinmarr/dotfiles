#!/usr/bin/env bash

# load nvm
export NVM_DIR="$HOME/.nvm"

NODE_GLOBALS=(`find ~/.nvm/versions/node -maxdepth 3 -type l -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)
NODE_GLOBALS+=(node nvm yarn nvim)

_load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

for cmd in "${NODE_GLOBALS[@]}"; do
    eval "function ${cmd}(){ unset -f ${NODE_GLOBALS[*]}; _load_nvm; unset -f _load_nvm; ${cmd} \$@; }"
done

unset cmd NODE_GLOBALS

# load pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
          
# Helpful functions / Aliases
alias gitrmbranches="git branch --list| grep -v \* | xargs git branch -D"
alias pipunall="pip freeze | grep -v '^-e' | xargs pip uninstall -y"
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias gpu="__GLX_VENDOR_LIBRARY_NAME=nvidia"
alias v="nvim"

alias updategrub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

update () {
    sudo test
    config submodule update --checkout --recursive
    git -C $NVM_DIR fetch --tags origin
    git -C $NVM_DIR checkout `git -C $NVM_DIR describe --abbrev=0 --tags --match "v[0-9]*" $(git -C $NVM_DIR rev-list --tags --max-count=1)`
    pyenv update
    yes o | yay -Syyu --answerclean A --answerdiff N --removemake
}

tzupdate () {
    timedatectl set-timezone $(curl https://ipapi.co/timezone)
}

gitc () {
    git add .
    git commit -m $1
    git push
}

export EDITOR=nvim
export GPG_TTY=$TTY

# Path Edits
export PATH="$HOME/.amplify/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
