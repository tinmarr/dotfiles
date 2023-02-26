# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || . ~/.p10k.zsh

setopt histignorealldups sharehistory
setopt autocd
unsetopt beep
unsetopt completealiases

# key binds
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^H' backward-kill-word
bindkey "^[[3~" delete-char

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# append completions to fpath
# Use modern completion system
zstyle :compinstall filename '/home/martin/.zshrc'

fpath=(~/.zsh/completions $fpath)

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# Plugins
. ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
. ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
. ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
. ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# setup history subsearch
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

. ~/.profile

# Load Colors
autoload -U colors && colors
local lc=$'\e[' rc=m

printf "$lc${color[magenta]}$rc""Welcome $(whoami)!$reset_color\n"
echo "Today is $(date +%A,\ %B\ %d,\ %Y)"
echo "The time now is $(date +%Hh%M)"

