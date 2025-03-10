#!/usr/bin/env bash

yay -Sy &> /dev/null
echo "$(pacman -Qu | wc -l)"
