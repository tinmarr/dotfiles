#!/usr/bin/env bash

setup_links () {
    link etc-ly-config.ini /etc/ly/config.ini
}

# link from_file /path/to/to_file
link () {
    if [[ ! -e $1 ]]; then
        printf "file $1 does not exist. skipping...\n"
        return
    fi

    sudo rm $2
    sudo ln -s $(readlink -e $1) $2
}

# enforce pwd as basepath
script_path="$(readlink -e $0 | xargs dirname)"
if [[ $script_path != $(pwd) ]]; then
    printf "please run this script from $script_path\n"
    exit 1
fi

# get sudo
sudo test

setup_links

