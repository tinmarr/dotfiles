#!/usr/bin/env bash

max_temp=6500
min_temp=2500

scan_time=1900 # time we start checking for gradient
start_time=2000 # time we start gradient
full_time=2200 # time we end gradient
end_time=0500

sleep_time="1h"

while true; do
    current_time=$(date +%-H%M)

    if [[ "$current_time" -lt "$scan_time" && "$current_time" -gt "$end_time" ]]; then
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
