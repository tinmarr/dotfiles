#!/usr/bin/env bash

hyprpaper &

bg_path=~/.local/share/backgrounds/
imgs=$(ls -1 $bg_path)

monitors=$(hyprctl monitors | grep Monitor | awk '{print $2}')

for i in $imgs; do
    hyprctl hyprpaper preload "$bg_path""$i"
done

while true; do
    bg=$(echo "$imgs" | shuf -n 1)
    for j in $monitors; do
	hyprctl hyprpaper wallpaper "$j"",""$bg_path""$bg"
    done
    sleep 15m
done
