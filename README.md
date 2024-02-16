# .dotfiles

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage all my dotfiles. I clone the repo in my home folder then run `stow .`

## To get onto new computer 

Install Arch normally. Then:
```shell
curl "https://raw.githubusercontent.com/tinmarr/dotfiles/main/.local/bin/archpost" > archpost && \
./archpost && \
rm archpost
```
## GPG

Currently I use a GPG key that expires every month. 

#### To generate a new one:

```shell
gpg --full-generate-key
```

Make sure to use the following settings:

- RSA
- 4096 bits
- 1m
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
