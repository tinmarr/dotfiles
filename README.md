# .dotfiles

[Article used to set this up](https://www.atlassian.com/git/tutorials/dotfiles)

TLDR:
There's a config command used for all git operations involving this repo.

Example flow

```shell
config status
config add .vimrc
config commit -m "Add vimrc"
config add .bashrc
config commit -m "Add bashrc"
config push
```

### To get onto new computer

Install the following.

```shell
sudo pacman -S --needed awesome git base-devel openssl zlib xz tk python-pip python-pygments github-cli zsh openssh lxsession picom kdeconnect neovim alacritty bemenu acpi acpilight pavucontrol alsa-utils exa betterlockscreen
```

Then:

```shell
chsh -s /bin/zsh
sudo usermod -a -G video $USER
cd $HOME
gh auth login # login with ssh 
gh repo clone tinmarr/.dotfiles -- --bare
mv .dotfiles.git .dotfiles
git --git-dir=.dotfiles --work-tree=. checkout -f
git --git-dir=.dotfiles --work-tree=. submodule update --init --recursive
git --git-dir=.dotfiles --work-tree=. config --local status.showUntrackedFiles no
fc-cache -f -v
curl https://pyenv.run | bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
python -m ensurepip
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay
yay -S nvim-packer-git
nvim # Then run :PackerSync
exec zsh
update
```

### GPG

Currently I use a GPG key that expires every month. To generate a new one do:

```shell
gpg --full-generate-key
```

Make sure to use the following settings:
- RSA
- 4096 bits
- 1m
- Name: GithubMartinMmmDD
- Email: martin.chapino@gmail.com

Next get the key ID with `gpg --list-secret-keys --keyid-format=long`.
Then get the key block with `gpg --armor --export [key id]`. Use this to import
the key into Github.

Finally update the git config signing key with `git config --global -e`.

To delete a key:

```shell
gpg --list-secret-keys # get uid
gpg --delete-secret-key [uid]
```

To export a key: 

```shell
gpg --export ${ID} > public.key
gpg --export-secret-key ${ID} > private.key
```

To import a key:

```shell
gpg --import public.key
gpg --import private.key
```

### Touchpad Configuration

`/etc/X11/xorg.conf.d/30-touchpad.conf`

```shell
Section "InputClass"
    Identifier "devname"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "ClickMethod" "clickfinger"
    Option "NaturalScrolling" "true"
EndSection
```

### Keyboard Configuration

`localectl --no-convert set-x11-keymap us [XkbModel] "" "compose:ralt"`

Use `cat /etc/x11/xorg.conf.org/00-keyboard.conf` to check default options
(only before running command).

### Useful things to install

```shell
yay -S lxappearance gnu-free-fonts neofetch ly brave-nightly-bin thunar visual-studio-code-bin gnome-keyring libsecret libgnome-keyring obsidian btop ranger man
```

Once these are installed, this is what needs to be configured.

- lxappearance
- ly (`sudo systemctl enable ly`)
- brave
- visual-studio-code
- obsidian (`gh repo clone tinmarr/obsidian-vault`)
