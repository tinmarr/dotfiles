#!/usr/bin/env bash
set -euo pipefail

data=$(curl -s "wttr.in?format=j1" 2>/dev/null) || { echo ""; exit 0; }

temp=$(echo "$data" | jq -r '.current_condition[0].temp_C // empty') || { echo ""; exit 0; }
code=$(echo "$data" | jq -r '.current_condition[0].weatherCode // empty') || { echo ""; exit 0; }

[ -z "$temp" ] && { echo ""; exit 0; }

case "$code" in
    113) icon="";;           # Sunny/Clear
    116) icon="" ;;           # Partly Cloudy
    119|122) icon="";;       # Cloudy/Overcast
    143|248|260) icon="";;   # Fog/Mist
    176|185|263|266|281|284|293|296|299|302|305|308|311|353|356|359) icon="";; # Rain/Drizzle
    179|182|227|230|317|320|323|326|329|332|335|338|350|362|365|368|371|374|377) icon="";; # Snow
    200|386|389|392|395) icon="" ;; # Thunder
    *) icon="" ;;
esac

echo "$temp°C $icon"
