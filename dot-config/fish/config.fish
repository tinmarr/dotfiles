# No greeting
set -U fish_greeting

# No vi prompt
function fish_mode_prompt
end

# Setup pyenv
set -gx PYENV_ROOT "$HOME/.pyenv"
set -gx PATH "$PYENV_ROOT/bin" $PATH

# Setup go
set -gx GOPATH "$HOME/go"
set -gx PATH "$GOPATH/bin" $PATH

# add mason binaries to path (faster nvim & for opencode)
set -gx PATH "$HOME/.local/share/nvim/mason/bin" $PATH

direnv hook fish | source

# Standard Terminal Variables
set -gx LANG en_US.UTF-8
set -gx EDITOR "nvim"
set -gx GPG_TTY $TTY

# Use bat in manpages
set -gx MANROFFOPT "-c"
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

if status is-interactive
    # Load various shell utilities
    set -gx FZF_DEFAULT_OPTS "--height 40% --tmux center --layout reverse --border"
    fzf --fish | source
    zoxide init fish | source

    # vi mode
    set -g fish_key_bindings fish_vi_key_bindings

    # quick aliases
    alias ls "eza --icons --group-directories-first"
    alias l "ls"
    alias la "ls -a"
    alias ll "ls -l --git"
    alias lla "ls -l -a --git"
    alias v "nvim"
    alias t "tmux"
    alias s "ssh"
    alias h "history 0"
    alias lg "lazygit"
    alias ms "sudo test; metapac sync && metapac clean"
    alias sesh "sessionizer"
    alias oc "opencode"

    # macros
    abbr -a updategrub "sudo grub-mkconfig -o /boot/grub/grub.cfg"
    abbr -a pipunall "pip freeze | grep -v '^-e' | xargs pip uninstall -y"
    abbr -a watch-dirty "watch -n 0.5 'cat /proc/meminfo | rg Dirty --before-context=3 --after-context=1'"

    # yazi
    # https://yazi-rs.github.io/docs/quick-start#shell-wrapper
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    # theme
    fish_config theme choose catppuccin-mocha
    oh-my-posh init fish --config "~/.config/ohmyposh/theme.json" | source

    # keybinds
    bind -M insert ctrl-e,ctrl-f $HOME/.local/bin/sessionizer
    bind -M insert ctrl-k history-search-backward
    bind -M insert ctrl-j history-search-forward
end
