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

## To get onto new computer

Arch:
```shell
curl "https://raw.githubusercontent.com/tinmarr/.dotfiles/main/.local/bin/archpost" | bash
```

### Keyboard Configuration

The keyboard needs to be configured manually.

`localectl --no-convert set-x11-keymap us [XkbModel] "" "compose:ralt"`

Use `cat /etc/x11/xorg.conf.org/00-keyboard.conf` to check default options
(only before running command).

## GPG

Currently I use a GPG key that expires every month. 

#### To generate a new one:

```shell
gpg --full-generate-key
```

Make sure to use the following settings:

- RSA
- 4096 bits
- 0
- Name: GithubMartinMmmDD
- Email: martin.chapino@gmail.com

Next get the key ID with `gpg --list-secret-keys --keyid-format=long`.
Then get the key block with `gpg --armor --export [key id]`. Use this to import
the key into Github.

Finally update the git config signing key with `git config --global -e`.

#### To edit key:

```shell
gpg --edit-key [uid]
help # to see options
expire # to change expire date
```

#### To delete a key:

```shell
gpg --list-secret-keys # get uid
gpg --delete-secret-key [uid]
```

#### To export a key:

```shell
gpg --export [uid] > public.key
gpg --export-secret-key [uid] > private.key
```

#### To import a key:

```shell
gpg --import public.key
gpg --import private.key
```
