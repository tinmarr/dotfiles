#!/usr/bin/env bash

max_temp=6500
min_temp=2500

scan_time=1900 # time we start checking for gradient
start_time=1900 # time we start gradient
full_time=2100 # time we end gradient
end_time=0500

sleep_time="1h"

set_time() {
    loc_info=$(curl -s https://ipinfo.io)
    loc=$(echo $loc_info | jq -r .loc)
    lat=${loc%,*}
    lng=${loc#*,}
    tzid=$(echo $loc_info | jq -r .timezone)

    sun_info=$(curl -s "https://api.sunrise-sunset.org/json?lat=$lat&lng=$lng&tzid=$tzid" | jq .results)
    sunset=$(echo $sun_info | jq -r .sunset)
    sunrise=$(echo $sun_info | jq -r .sunrise)

    start_time=$(date -d "$sunset" "+%H%M")
    full_time=$(python -c "print($start_time + 200)")

    end_time=$(date -d "$sunrise" "+%H%M")
}

set_time

while true; do
    raw=$(date +%-H%M | sed "s/^0*//g")
    # maps the 60 minutes to a value between 0-100
    current_time=$(python -c "print(int(($raw // 100) * 100 + ($raw % 100)/60 * 100))")

    if [[ "$current_time" -gt 0 && "$current_time" -lt "$end_time" ]]; then
        echo "temps set to $min_temp"
        hyprctl -i 0 hyprsunset temperature $min_temp
        sleep_time=1h
    elif [[ "$current_time" -lt "$scan_time" && "$current_time" -gt "$end_time" ]]; then
        echo "reset"
        hyprctl -i 0 hyprsunset identity
        sleep_time=1h
    elif [[ "$current_time" -lt "$start_time" ]]; then
        sleep_time=10m
    elif [[ "$current_time" -ge "$start_time" && "$current_time" -le "$full_time" ]]; then
        lerp_t=$(python -c "print(($current_time - $start_time) / ($full_time - $start_time))" )
        temp_value=$(python -c "print($max_temp + ($min_temp - $max_temp) * $lerp_t)" )

        echo "temps set to $temp_value"
        hyprctl -i 0 hyprsunset temperature $temp_value
        sleep_time=5m
    else
        echo "temps set to $min_temp"
        hyprctl -i 0 hyprsunset temperature $min_temp
        sleep_time=1h
    fi

    if [[ -z "$1" ]]; then
        sleep $sleep_time
    else
        exit 0
    fi
done
