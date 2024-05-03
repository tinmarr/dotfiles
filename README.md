# .dotfiles

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage all my dotfiles stored at `~/dotfiles`

## "Tech stack"

![showcase image](https://github.com/tinmarr/dotfiles/blob/main/showcase.png?raw=true)

What do I actually use right now?
I've used quite a few things in the past and this repo houses all of configs for everything I've configured and used as a daily driver.

### Current stack:

* *OS*: Arch Linux
* *WM*: Hyprland
* *Display Server*: Wayland
* *Text editor/IDE*: GNU Emacs
* *Terminal Emulator*: Kitty
* *Shell*: ZSH
* *Themes*: Dracula... on everthing

### Past stacks:
*Note that I do not maintain these since I do not use the*

* *WMs*: QTile, AwesomeWM
* *Display Server*: X11
* *Terminal Emulators*: Alacritty

## To get onto new computer

Install Arch normally. Then:
```shell
curl "https://raw.githubusercontent.com/tinmarr/dotfiles/main/.local/bin/archpost" > archpost && \
./archpost && \
rm archpost
```
