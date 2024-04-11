#!/usr/bin/env bash

hyprpaper &

bg_path=~/.local/share/backgrounds/
imgs=$(ls -1 $bg_path)

monitors=$(hyprctl monitors | grep Monitor | awk '{print $2}')

while true; do
    bg=$(echo "$imgs" | shuf -n 1)
    hyprctl hyprpaper preload "$bg_path""$bg"
    for j in $monitors; do
	hyprctl hyprpaper wallpaper "$j"",""$bg_path""$bg"
    done
    hyprctl hyprpaper unload unused
    sleep 10m
done
