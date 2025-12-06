#!/usr/bin/env bash

hyprctl reload
systemctl restart --user waybar
systemctl stop --user sunsetctl.scope
kill $(pgrep -f sunsetctl.sh)
setsid -f uwsm app -u sunsetctl.scope -- systemd-cat -t sunsetctl ~/.config/hypr/sunsetctl.sh
