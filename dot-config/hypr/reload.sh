#!/usr/bin/env bash

hyprctl reload
systemctl restart --user waybar
systemctl stop --user sunsetctl.service
setsid -f app2unit -u sunsetctl.service -t service -s b -- systemd-cat -t sunsetctl ~/.config/hypr/sunsetctl.sh
systemctl stop --user awww-daemon.service
setsid -f app2unit -u awww-daemon.service -t service -s b -- awww-daemon
