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
    twilight=$(echo $sun_info | jq -r .civil_twilight_end)
    sunrise=$(echo $sun_info | jq -r .sunrise)

    start_time=$(date -d "$sunset" "+%H%M" | sed 's/^0*//')
    full_time=$(date -d "$twilight" "+%H%M" | sed 's/^0*//')

    echo $start_time
    echo $full_time

    end_time=$(date -d "$sunrise" "+%H%M" | sed 's/^0*//')
}

# Calculate minutes until target time, handling midnight wrap
minutes_until() {
    local target=$1 current=$2
    local target_h=$((target / 100))
    local target_m=$((target % 100))
    local current_h=$((current / 100))
    local current_m=$((current % 100))

    local target_minutes=$((target_h * 60 + target_m))
    local current_minutes=$((current_h * 60 + current_m))

    if (( target_minutes > current_minutes )); then
        echo $((target_minutes - current_minutes))
    else
        echo $((1440 - current_minutes + target_minutes))
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
    current_time=$(date +%H%M | sed 's/^0*//')

    # During gradient transition (sunset to full darkness)
    if [[ "$current_time" -ge "$start_time" && "$current_time" -le "$full_time" ]]; then
        lerp_t=$(python -c "print(($current_time - $start_time) / ($full_time - $start_time))")
        temp_value=$(python -c "print($max_temp + ($min_temp - $max_temp) * $lerp_t)")
        echo "Gradient: $temp_value K"
        hyprctl -i 0 hyprsunset temperature "$temp_value"
        if [[ -z "$1" ]]; then
            sleep 10m
        fi
    # During night (full darkness)
    elif [[ "$current_time" -gt "$full_time" || "$current_time" -lt "$end_time" ]]; then
        mins=$(minutes_until "$end_time" "$current_time")
        formatted=$(format_sleep "$mins")
        echo "Night: $min_temp K. Sleeping for $formatted"
        hyprctl -i 0 hyprsunset temperature "$min_temp"
        if [[ -z "$1" ]]; then
            sleep $formatted
        fi
    # Before sunset
    else
        mins=$(format_sleep $(minutes_until "$start_time" "$current_time"))
        echo "Day: waiting $mins for sunset"
        hyprctl -i 0 hyprsunset identity
        if [[ -z "$1" ]]; then
            sleep $mins
        fi
    fi

    if [[ -n "$1" ]]; then
        exit 0
    fi
done
