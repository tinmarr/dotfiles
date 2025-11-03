#!/usr/bin/env bash

max_temp=6500
min_temp=2500

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

# Calculate minutes until target time, handling midnight wrap
minutes_until() {
    local target=$1 current=$2
    if (( target > current )); then
        echo $((target - current))
    else
        echo $((2400 - current + target))
    fi
}

# Format minutes as sleep duration
format_sleep() {
    local mins=$1
    local hours=$((mins / 60))
    local remaining=$((mins % 60))
    [[ $hours -gt 0 ]] && echo "${hours}h ${remaining}m" || echo "${remaining}m"
}

set_time

while true; do
    current_time=$(date +%-H%M | sed "s/^0*//g")

    # During gradient transition (sunset to full darkness)
    if [[ "$current_time" -ge "$start_time" && "$current_time" -le "$full_time" ]]; then
        lerp_t=$(python -c "print(($current_time - $start_time) / ($full_time - $start_time))")
        temp_value=$(python -c "print($max_temp + ($min_temp - $max_temp) * $lerp_t)")
        echo "Gradient: $temp_value K"
        hyprctl -i 0 hyprsunset temperature "$temp_value"
        sleep 10m
    # During night (full darkness)
    elif [[ "$current_time" -gt "$full_time" || "$current_time" -lt "$end_time" ]]; then
        mins=$(minutes_until "$end_time" "$current_time")
        formatted=$(format_sleep "$mins")
        echo "Night: $min_temp K. Sleeping for $formatted"
        hyprctl -i 0 hyprsunset temperature "$min_temp"
        sleep $formatted
    # Before sunset
    else
        mins=$(format_sleep $(minutes_until "$start_time" "$current_time"))
        echo "Day: waiting $mins for sunset"
        hyprctl -i 0 hyprsunset identity
        sleep $mins
    fi

    if [[ -n "$1" ]]; then
        exit 0
    fi
done
