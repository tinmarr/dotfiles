#!/usr/bin/env bash
set -euo pipefail

readonly CONNECTING=''
readonly CONNECTED=''
readonly DISCONNECT=''
readonly AIRPLANE=''

readonly DEVICE=$(iw dev | awk '/Interface/{iface=$2} END{print iface}')

dbus-monitor path="/org/freedesktop/portal/desktop" interface="org.freedesktop.portal.NetworkMonitor" member="changed" --profile |
    while read -r _; do
        line=$(nmcli device show $DEVICE | rg STATE)
        if [[ $line =~ "100" ]]; then
            echo $CONNECTED
        elif [[ $line =~ "30" ]]; then
            echo $DISCONNECT
        elif [[ $line =~ "20" ]]; then
            echo $AIRPLANE
        elif [[ $line =~ "[3-9]0" ]]; then
            echo $CONNECTING
        fi
    done
