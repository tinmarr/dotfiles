# .dotfiles

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage all my dotfiles stored at `~/dotfiles`

## "Tech stack"

![showcase image](https://github.com/tinmarr/dotfiles/blob/main/showcase.png?raw=true)

What do I actually use right now?
I've used quite a few things in the past and this repo houses all of configs for everything I've configured and used as a daily driver.

### Current stack:

- _OS_: Arch Linux
- _WM_: Hyprland
- _Text editor/IDE_: Neovim
- _Terminal Emulator_: Ghostty
- _Shell_: Fish
- _Themes_: Catppuccin

### Past stacks:

_Note that I do not maintain these since I do not use them._

You can see the configuration for these in [this repo](https://github.com/tinmarr/dotfiles-archive)

- _WMs_: QTile, AwesomeWM
- _Text editor/IDE_: GNU Emacs
- _Terminal Emulators_: Alacritty, Kitty
- _Shells_: ZSH
- _Themes_: Dracula

## To get onto new computer

Install Arch normally. Then:

```shell
curl "https://raw.githubusercontent.com/tinmarr/dotfiles/main/install/archpost" > archpost && chmod +x archpost && \
./archpost && \
rm archpost
```
