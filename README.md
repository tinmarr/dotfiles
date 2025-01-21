# .dotfiles

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage all my dotfiles stored at `~/dotfiles`

## "Tech stack"

![showcase image](https://github.com/tinmarr/dotfiles/blob/main/showcase.png?raw=true)

What do I actually use right now?
I've used quite a few things in the past and this repo houses all of configs for everything I've configured and used as a daily driver.

### Current stack:

* *OS*: Arch Linux
* *WM*: Hyprland
* *Text editor/IDE*: Neovim
* *Terminal Emulator*: Ghostty
* *Shell*: ZSH
* *Themes*: Catppuccin

### Past stacks:
*Note that I do not maintain these since I do not use the*

* *WMs*: QTile, AwesomeWM
* *Text editor/IDE*: GNU Emacs
* *Terminal Emulators*: Alacritty, Kitty
* *Themes*: Dracula

## To get onto new computer

Install Arch normally. Then:
```shell
curl "https://raw.githubusercontent.com/tinmarr/dotfiles/main/dot-local/bin/archpost" > archpost && chmod +x archpost && \
./archpost && \
rm archpost
```
