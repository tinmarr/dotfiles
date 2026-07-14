#!/usr/bin/env bash

set -euo pipefail

# Open a Walker menu for selecting a monitor and setting its brightness.
# Discovery is intentionally on-demand: unlike the old Waybar helper this
# script has no watcher, event listener, or periodic DDC polling.

readonly DETECT_TIMEOUT_SECONDS=10
readonly VALUE_TIMEOUT_SECONDS=5

declare -A DDC_BUS_BY_CONNECTOR=()
declare -A DDC_MODEL_BY_CONNECTOR=()
declare -A DDC_SERIAL_BY_CONNECTOR=()
declare -A DDC_MAX_BY_CONNECTOR=()

TARGET_OUTPUT=''
TARGET_KIND=''
TARGET_DEVICE=''
TARGET_BUS=''
TARGET_CURRENT=''
TARGET_MAX=''
TARGET_PERCENT=''
TARGET_LABEL=''
MENU_DIR=''
MENU_PRODUCER_PID=0

cleanup() {
    if ((MENU_PRODUCER_PID)); then
        kill "$MENU_PRODUCER_PID" 2>/dev/null || true
        wait "$MENU_PRODUCER_PID" 2>/dev/null || true
    fi
    [[ -n $MENU_DIR ]] && rm -rf "$MENU_DIR"
}

trim() {
    local value=$1

    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

normalize_connector() {
    local connector

    connector=$(trim "$1")
    if [[ $connector =~ ^card[0-9]+-(.*)$ ]]; then
        connector=${BASH_REMATCH[1]}
    fi

    printf '%s\n' "$connector"
}

flush_ddc_display() {
    local connector=${CURRENT_DDC_CONNECTOR:-}
    local bus=${CURRENT_DDC_BUS:-}

    if [[ -z $connector || ! $bus =~ ^[0-9]+$ ]]; then
        return 0
    fi
    if [[ ${CURRENT_DDC_IS_INTERNAL:-false} == true ]]; then
        return 0
    fi

    DDC_BUS_BY_CONNECTOR["$connector"]=$bus
    DDC_MODEL_BY_CONNECTOR["$connector"]=${CURRENT_DDC_MODEL:-$connector}
    DDC_SERIAL_BY_CONNECTOR["$connector"]=${CURRENT_DDC_SERIAL:-}
    DDC_MAX_BY_CONNECTOR["$connector"]=${CURRENT_DDC_MAX:-100}
    return 0
}

discover_ddc() {
    local line

    DDC_BUS_BY_CONNECTOR=()
    DDC_MODEL_BY_CONNECTOR=()
    DDC_SERIAL_BY_CONNECTOR=()
    DDC_MAX_BY_CONNECTOR=()

    CURRENT_DDC_CONNECTOR=''
    CURRENT_DDC_BUS=''
    CURRENT_DDC_IS_INTERNAL='false'
    CURRENT_DDC_MODEL=''
    CURRENT_DDC_SERIAL=''
    CURRENT_DDC_MAX='100'

    while IFS= read -r line; do
        if [[ $line =~ ^Display[[:space:]]+[0-9]+ ]]; then
            flush_ddc_display
            CURRENT_DDC_CONNECTOR=''
            CURRENT_DDC_BUS=''
            CURRENT_DDC_IS_INTERNAL='false'
            CURRENT_DDC_MODEL=''
            CURRENT_DDC_SERIAL=''
            CURRENT_DDC_MAX='100'
        elif [[ $line =~ I2C[[:space:]]+bus:[[:space:]]*/dev/i2c-([0-9]+) ]]; then
            CURRENT_DDC_BUS=${BASH_REMATCH[1]}
        elif [[ $line =~ DRM[_[:space:]]+connector:[[:space:]]+(.+) ]]; then
            CURRENT_DDC_CONNECTOR=$(normalize_connector "${BASH_REMATCH[1]}")
        elif [[ $line =~ Is[[:space:]]+LVDS[[:space:]]+or[[:space:]]+EDP[[:space:]]+display:[[:space:]]+(true|false) ]]; then
            CURRENT_DDC_IS_INTERNAL=${BASH_REMATCH[1]}
        elif [[ $line =~ Is[[:space:]]+eDP[[:space:]]+device:[[:space:]]+(true|false) ]]; then
            CURRENT_DDC_IS_INTERNAL=${BASH_REMATCH[1]}
        elif [[ $line =~ Model:[[:space:]]+(.+) ]]; then
            CURRENT_DDC_MODEL=$(trim "${BASH_REMATCH[1]}")
        elif [[ $line =~ Serial[[:space:]]+number:[[:space:]]+(.+) ]]; then
            CURRENT_DDC_SERIAL=$(trim "${BASH_REMATCH[1]}")
        fi
    done < <(timeout "$DETECT_TIMEOUT_SECONDS" ddcutil detect --verbose 2>/dev/null || true)

    flush_ddc_display
}

select_backlight_device() {
    local device

    if [[ -n ${BACKLIGHT_DEVICE:-} && -e "/sys/class/backlight/$BACKLIGHT_DEVICE" ]]; then
        printf '%s\n' "$BACKLIGHT_DEVICE"
        return 0
    fi

    # Only enumerate the real backlight class. In particular, never include
    # keyboard, Ethernet, or other entries from /sys/class/leds.
    for device in /sys/class/backlight/*; do
        [[ -e $device ]] || continue
        basename "$device"
        return 0
    done

    return 1
}

read_sysfs_value() {
    local device=$1
    local path="/sys/class/backlight/$device"
    local current max

    [[ -r $path/brightness && -r $path/max_brightness ]] || return 1
    current=$(<"$path/brightness")
    max=$(<"$path/max_brightness")
    [[ $current =~ ^[0-9]+$ && $max =~ ^[1-9][0-9]*$ ]] || return 1
    printf '%s %s\n' "$current" "$max"
}

read_ddc_value() {
    local bus=$1
    local terse

    terse=$(timeout "$VALUE_TIMEOUT_SECONDS" ddcutil --bus "$bus" \
        getvcp 10 --terse 2>/dev/null) || return 1

    awk '$1 == "VCP" && toupper($2) == "10" && $3 == "C" {
        print $4, $5
        exit
    }' <<< "$terse"
}

percent_for_value() {
    local current=$1
    local max=$2
    local percent=$((current * 100 / max))

    ((percent < 0)) && percent=0
    ((percent > 100)) && percent=100
    printf '%s\n' "$percent"
}

append_menu_item() {
    local state_file=$1
    local output=$2
    local kind=$3
    local device=$4
    local bus=$5
    local current=$6
    local max=$7
    local percent=$8
    local label=$9

    # Write the metadata before the corresponding display row. Walker's
    # dmenu index then maps directly to this file, including streamed rows.
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$output" "$kind" "$device" "$bus" "$current" "$max" "$percent" "$label" \
        >> "$state_file"
    printf '%s\n' "$label" >&3
}

stream_monitors() {
    local fifo=$1
    local state_file=$2
    local output description device bus value current max percent label model serial index
    local -a outputs=()
    local -a descriptions=()

    exec 3>"$fifo"

    # Enumerate Hyprland outputs immediately and stream the internal panel
    # before the slower DDC probe starts. If there is no internal panel, Walker
    # opens with an empty list and receives the external rows below.
    while IFS=$'\t' read -r output description; do
        [[ -n $output ]] || continue
        outputs+=("$output")
        descriptions+=("${description:-$output}")

        if [[ $output =~ ^(eDP|LVDS|DSI)- ]]; then
            if device=$(select_backlight_device) && value=$(read_sysfs_value "$device"); then
                read -r current max <<< "$value"
                percent=$(percent_for_value "$current" "$max")
                label="󰃠  ${description:-$output} (${output}) — ${percent}%"
                append_menu_item "$state_file" "$output" sysfs "$device" - \
                    "$current" "$max" "$percent" "$label"
            fi
        fi
    done < <(timeout 2 hyprctl monitors -j 2>/dev/null \
        | jq -r '.[] | [.name, (.description // .name)] | @tsv' || true)

    # DDC discovery and VCP reads happen while the Walker window is already
    # visible. Each usable external monitor is appended as soon as its value
    # is available.
    discover_ddc
    for index in "${!outputs[@]}"; do
        output=${outputs[$index]}
        description=${descriptions[$index]}
        [[ $output =~ ^(eDP|LVDS|DSI)- ]] && continue
        bus=${DDC_BUS_BY_CONNECTOR[$output]:-}
        [[ -n $bus ]] || continue
        value=$(read_ddc_value "$bus") || continue
        read -r current max <<< "$value"
        [[ $current =~ ^[0-9]+$ && $max =~ ^[1-9][0-9]*$ ]] || continue
        percent=$(percent_for_value "$current" "$max")
        model=${DDC_MODEL_BY_CONNECTOR[$output]:-$description}
        serial=${DDC_SERIAL_BY_CONNECTOR[$output]:-}
        [[ -n $serial ]] && model+=" (${serial})"
        label="󰍹  ${model} (${output}) — ${percent}%"
        append_menu_item "$state_file" "$output" ddc - "$bus" \
            "$current" "$max" "$percent" "$label"
    done

    exec 3>&-
}

load_selected_item() {
    local state_file=$1
    local selected_index=$2
    local record

    [[ $selected_index =~ ^[0-9]+$ ]] || return 1
    record=$(sed -n "$((selected_index + 1))p" "$state_file")
    IFS=$'\t' read -r TARGET_OUTPUT TARGET_KIND TARGET_DEVICE TARGET_BUS \
        TARGET_CURRENT TARGET_MAX TARGET_PERCENT TARGET_LABEL <<< "$record"
    [[ -n $TARGET_OUTPUT && $TARGET_KIND != loading ]] || return 1
}

choose_brightness() {
    local current=$TARGET_PERCENT
    local value selected

    selected=$(for ((value = 0; value <= 100; value += 5)); do
        if ((value == current)); then
            printf '%s%% (current)\n' "$value"
        else
            printf '%s%%\n' "$value"
        fi
    done | walker -d -N -p "Set brightness (${TARGET_OUTPUT})") || return 1

    value=${selected%%\%*}
    [[ $value =~ ^[0-9]+$ && $value -le 100 ]] || return 1
    printf '%s\n' "$value"
}

set_brightness() {
    local percent=$1
    local target

    if [[ $TARGET_KIND == sysfs ]]; then
        brightnessctl --device "$TARGET_DEVICE" set "${percent}%"
        return
    fi

    target=$((percent * TARGET_MAX / 100))
    timeout "$VALUE_TIMEOUT_SECONDS" ddcutil --bus "$TARGET_BUS" \
        setvcp 10 "$target" --noverify
}

main() {
    local fifo state_file selected_index percent runtime_dir

    runtime_dir=${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}
    if [[ ! -d $runtime_dir || ! -w $runtime_dir ]]; then
        runtime_dir=${TMPDIR:-/tmp}
    fi
    MENU_DIR=$(mktemp -d "$runtime_dir/brightness-menu.XXXXXX")
    fifo="$MENU_DIR/items.fifo"
    state_file="$MENU_DIR/items.tsv"
    mkfifo "$fifo"

    trap cleanup EXIT INT TERM

    stream_monitors "$fifo" "$state_file" &
    MENU_PRODUCER_PID=$!

    # Walker reads the FIFO as a streaming dmenu source. Any internal row is
    # available immediately; DDC-backed rows arrive while this window is up.
    selected_index=$(walker -d -N -i -p 'Select monitor' < "$fifo") || exit 0
    load_selected_item "$state_file" "$selected_index" || exit 0
    percent=$(choose_brightness) || exit 0
    set_brightness "$percent"
}

main "$@"
