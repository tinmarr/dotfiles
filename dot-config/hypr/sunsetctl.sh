#!/usr/bin/env bash

set -euo pipefail

max_temp=6500
min_temp=2500

start_time=1900 # time we start gradient
full_time=2100 # time we end gradient
end_time=0500

script_path="${BASH_SOURCE[0]}"
if command -v realpath >/dev/null 2>&1; then
    script_path=$(realpath "$script_path")
fi

set_time() {
    if ! loc_info=$(timeout 2s curl -fsS https://ipinfo.io); then
        return
    fi
    loc=$(echo "$loc_info" | jq -r .loc)
    lat=${loc%,*}
    lng=${loc#*,}
    tzid=$(echo "$loc_info" | jq -r .timezone)

    if ! sun_info=$(timeout 2s curl -fsS "https://api.sunrise-sunset.org/json?lat=$lat&lng=$lng&tzid=$tzid" | jq .results); then
        return
    fi
    sunset=$(echo "$sun_info" | jq -r .sunset)
    twilight=$(echo "$sun_info" | jq -r .civil_twilight_end)
    sunrise=$(echo "$sun_info" | jq -r .sunrise)

    start_time=$(date -d "$sunset" "+%H%M" | sed 's/^0*//')
    full_time=$(date -d "$twilight" "+%H%M" | sed 's/^0*//')
    end_time=$(date -d "$sunrise" "+%H%M" | sed 's/^0*//')
}

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

schedule_next_run() {
    local calendar=$(date -d "+$1" "+%Y-%m-%d %H:%M:%S")
    local unit_name="sunsetctl-$(date +%s)-$$"
    echo "Scheduling next update on $calendar"
    systemd-run --user --quiet --slice="background-graphical.slice" --unit="$unit_name" --on-calendar="$calendar" systemd-cat -t sunsetctl "$script_path"
}

# Cleanup timers
(systemctl --user list-timers | rg "sunsetctl.*\.timer" -o | xargs systemctl --user stop) 2> /dev/null || true

set_time
current_time=$(date +%H%M | sed 's/^0*//')

# During gradient transition (sunset to full darkness)
if [[ "$current_time" -ge "$start_time" && "$current_time" -le "$full_time" ]]; then
    lerp_t=$(python -c "print(($current_time - $start_time) / ($full_time - $start_time))")
    temp_value=$(python -c "print($max_temp + ($min_temp - $max_temp) * $lerp_t)")
    echo "Gradient: $temp_value K"
    hyprctl -i 0 hyprsunset temperature "$temp_value"
    schedule_next_run "10m"
# During night (full darkness)
elif [[ "$current_time" -gt "$full_time" || "$current_time" -lt "$end_time" ]]; then
    mins=$(minutes_until "$end_time" "$current_time")
    hours=$((mins / 60))
    remaining=$((mins % 60))
    delay="${hours}hour ${remaining}min"
    echo "Night: $min_temp K. Scheduling next update in $delay ($full_time)"
    hyprctl -i 0 hyprsunset temperature "$min_temp"
    schedule_next_run "$delay"
# Before sunset
else
    mins=$(minutes_until "$start_time" "$current_time")
    hours=$((mins / 60))
    remaining=$((mins % 60))
    delay="${hours}hour ${remaining}min"
    echo "Day: waiting $delay for sunset ($start_time)"
    hyprctl -i 0 hyprsunset identity
    schedule_next_run "$delay"
fi
