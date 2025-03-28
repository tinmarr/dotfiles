#!/usr/bin/env bash

max_temp=6500
min_temp=2500

start_time=1800
full_time=2000
end_time=7

while true; do
    current_time=$(date +%H%M)

    if [[ "$current_time" -lt "$start_time" && "$current_time" -gt "$end_time" ]]; then
        echo "reset"
        hyprctl -i 0 hyprsunset identity
        sleep 1h
    elif [[ "$current_time" -ge "$start_time" && "$current_time" -le "$full_time" ]]; then
        lerp_t=$(python -c "print(($current_time - $start_time) / ($full_time - $start_time))" )
        temp_value=$(python -c "print($max_temp + ($min_temp - $max_temp) * $lerp_t)" )

        echo "temps set to $temp_value"
        hyprctl -i 0 hyprsunset temperature $temp_value
        sleep 5m
    else
        echo "temps set to $min_temp"
        hyprctl -i 0 hyprsunset temperature $min_temp
        sleep 1h
    fi
done
