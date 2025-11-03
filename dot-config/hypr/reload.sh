#!/usr/bin/env bash

hyprctl reload
systemctl restart --user waybar
pkill -g $(pgrep -f sunsetctl.sh) -TERM
setsid -f uwsm app -u sunsetctl.scope -- systemd-cat -t sunsetctl ~/.config/hypr/sunsetctl.sh
