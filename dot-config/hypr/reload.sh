#!/usr/bin/env bash

hyprctl reload
systemctl restart --user waybar
pkill -f sunsetctl.sh
setsid -f uwsm app -- ~/.config/hypr/sunsetctl.sh
