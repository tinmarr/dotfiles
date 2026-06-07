#!/usr/bin/env bash

set -e pipefail

setup_links () {
    link ./autologin.conf /etc/systemd/system/getty@tty1.service.d/autologin.conf
}

# link from_file /path/to/to_file
link () {
    if [[ ! -e $1 ]]; then
        printf "file $1 does not exist. skipping...\n"
        return
    fi

    sudo rm -f $2
    sudo ln -s $(readlink -e $1) $2
}

# enforce pwd as basepath
script_path="$(readlink -e $0 | xargs dirname)"
if [[ $script_path != $(pwd) ]]; then
    printf "please run this script from $script_path\n"
    exit 1
fi

# get sudo
sudo true

setup_links

echo "Links setup. Run the following to finish:"
echo "- sudo systemctl edit getty@tty1 --drop-in=autologin"
