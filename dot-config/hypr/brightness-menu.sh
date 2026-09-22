#!/usr/bin/env bash

set -euo pipefail

# Open a Walker menu for selecting a monitor and setting its brightness.
# The I2C bus mapping is cached in the runtime directory. Hyprland output
# events refresh it in the background, with discovery as a fallback on cache
# misses or stale bus mappings.

readonly DETECT_TIMEOUT_SECONDS=10
readonly VALUE_TIMEOUT_SECONDS=5
readonly CACHE_VALUE_TIMEOUT_SECONDS=1
readonly NEGATIVE_CACHE_TTL_SECONDS=60

cache_directory() {
    local runtime_dir=${XDG_RUNTIME_DIR:-}

    if [[ -n $runtime_dir && -d $runtime_dir && -w $runtime_dir ]]; then
        printf '%s/brightness-menu\n' "$runtime_dir"
    else
        printf '%s/brightness-menu-%s\n' "${TMPDIR:-/tmp}" "$UID"
    fi
}

readonly CACHE_DIR=$(cache_directory)
readonly CACHE_FILE="$CACHE_DIR/ddc-buses.tsv"

declare -A DDC_BUS_BY_CONNECTOR=()
declare -A DDC_MODEL_BY_CONNECTOR=()
declare -A DDC_SERIAL_BY_CONNECTOR=()
declare -A DDC_MAX_BY_CONNECTOR=()
declare -A DDC_NO_DDC_BY_CONNECTOR=()
declare -A DDC_CURRENT_VALUE_BY_CONNECTOR=()

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
    local line detect_output detect_status=0

    DDC_BUS_BY_CONNECTOR=()
    DDC_MODEL_BY_CONNECTOR=()
    DDC_SERIAL_BY_CONNECTOR=()
    DDC_MAX_BY_CONNECTOR=()
    DDC_NO_DDC_BY_CONNECTOR=()
    DDC_CURRENT_VALUE_BY_CONNECTOR=()

    CURRENT_DDC_CONNECTOR=''
    CURRENT_DDC_BUS=''
    CURRENT_DDC_IS_INTERNAL='false'
    CURRENT_DDC_MODEL=''
    CURRENT_DDC_SERIAL=''
    CURRENT_DDC_MAX='100'

    detect_output=$(timeout "$DETECT_TIMEOUT_SECONDS" ddcutil detect --verbose 2>/dev/null) || detect_status=$?

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
    done <<< "$detect_output"

    flush_ddc_display
    ((detect_status == 0))
}

get_hypr_monitor_tsv() {
    local monitor_json

    monitor_json=$(timeout 2 hyprctl monitors -j 2>/dev/null) || return 1
    jq -r '.[] | [.name, (.description // .name)] | @tsv' <<< "$monitor_json"
}

is_external_output() {
    [[ ! $1 =~ ^(eDP|LVDS|DSI)- ]]
}

load_ddc_cache() {
    local record output rest bus model serial

    DDC_BUS_BY_CONNECTOR=()
    DDC_MODEL_BY_CONNECTOR=()
    DDC_SERIAL_BY_CONNECTOR=()
    DDC_MAX_BY_CONNECTOR=()
    DDC_NO_DDC_BY_CONNECTOR=()
    DDC_CURRENT_VALUE_BY_CONNECTOR=()

    [[ -r $CACHE_FILE ]] || return 0

    while IFS= read -r record || [[ -n $record ]]; do
        [[ -n $record && $record != \#* ]] || continue
        [[ $record == *$'\t'* ]] || continue

        output=${record%%$'\t'*}
        rest=${record#*$'\t'}
        bus=${rest%%$'\t'*}
        if [[ $rest == *$'\t'* ]]; then
            rest=${rest#*$'\t'}
            model=${rest%%$'\t'*}
            serial=${rest#*$'\t'}
        else
            model=''
            serial=''
        fi

        [[ -n $output ]] || continue
        if [[ $bus =~ ^[0-9]+$ ]]; then
            DDC_BUS_BY_CONNECTOR["$output"]=$bus
            DDC_MODEL_BY_CONNECTOR["$output"]=${model:-$output}
            DDC_SERIAL_BY_CONNECTOR["$output"]=$serial
            DDC_MAX_BY_CONNECTOR["$output"]=100
        elif [[ $bus == - ]]; then
            DDC_NO_DDC_BY_CONNECTOR["$output"]=true
        fi
    done < "$CACHE_FILE"
}

cache_is_current() {
    local output bus value has_external=false has_negative=false
    local cache_mtime now

    DDC_CURRENT_VALUE_BY_CONNECTOR=()

    for output in "$@"; do
        is_external_output "$output" || continue
        has_external=true
    done
    [[ $has_external == true ]] || return 0
    [[ -r $CACHE_FILE ]] || return 1

    for output in "$@"; do
        is_external_output "$output" || continue
        bus=${DDC_BUS_BY_CONNECTOR[$output]:-}
        if [[ $bus =~ ^[0-9]+$ ]]; then
            value=$(read_ddc_value "$bus" "$CACHE_VALUE_TIMEOUT_SECONDS") || return 1
            [[ $value =~ ^[0-9]+[[:space:]]+[1-9][0-9]*$ ]] || return 1
            DDC_CURRENT_VALUE_BY_CONNECTOR["$output"]=$value
        elif [[ ${DDC_NO_DDC_BY_CONNECTOR[$output]:-false} == true ]]; then
            has_negative=true
        else
            return 1
        fi
    done

    if [[ $has_negative == true ]]; then
        cache_mtime=$(stat -c %Y "$CACHE_FILE" 2>/dev/null) || return 1
        now=$(date +%s) || return 1
        ((now - cache_mtime < NEGATIVE_CACHE_TTL_SECONDS)) || return 1
    fi

    return 0
}

write_ddc_cache() {
    local mark_missing=$1
    shift

    local temporary_file output bus model serial

    mkdir -p -m 700 -- "$CACHE_DIR"
    chmod 700 "$CACHE_DIR"
    temporary_file=$(mktemp "$CACHE_DIR/ddc-buses.XXXXXX") || return 1
    printf '# connector\tbus\tmodel\tserial\n' > "$temporary_file"

    for output in "$@"; do
        is_external_output "$output" || continue
        bus=${DDC_BUS_BY_CONNECTOR[$output]:-}
        model=${DDC_MODEL_BY_CONNECTOR[$output]:-}
        serial=${DDC_SERIAL_BY_CONNECTOR[$output]:-}

        if [[ $bus =~ ^[0-9]+$ ]]; then
            printf '%s\t%s\t%s\t%s\n' "$output" "$bus" "$model" "$serial" \
                >> "$temporary_file"
        elif [[ ${DDC_NO_DDC_BY_CONNECTOR[$output]:-false} == true || $mark_missing == true ]]; then
            printf '%s\t-\t\t\n' "$output" >> "$temporary_file"
        fi
    done

    mv -f -- "$temporary_file" "$CACHE_FILE"
}

update_ddc_cache() {
    local lock_fd monitor_tsv output description
    local -a outputs=()

    mkdir -p -m 700 -- "$CACHE_DIR"
    chmod 700 "$CACHE_DIR"
    exec {lock_fd}>"$CACHE_DIR/update.lock"
    flock "$lock_fd"

    if ! monitor_tsv=$(get_hypr_monitor_tsv); then
        exec {lock_fd}>&-
        return 1
    fi

    while IFS=$'\t' read -r output description; do
        [[ -n $output ]] || continue
        outputs+=("$output")
    done <<< "$monitor_tsv"

    load_ddc_cache
    if cache_is_current "${outputs[@]}"; then
        exec {lock_fd}>&-
        return 0
    fi

    if ! discover_ddc; then
        exec {lock_fd}>&-
        return 1
    fi

    write_ddc_cache true "${outputs[@]}"
    exec {lock_fd}>&-
}

prune_ddc_cache() {
    local lock_fd monitor_tsv output description
    local -a outputs=()

    mkdir -p -m 700 -- "$CACHE_DIR"
    chmod 700 "$CACHE_DIR"
    exec {lock_fd}>"$CACHE_DIR/update.lock"
    flock "$lock_fd"

    if ! monitor_tsv=$(get_hypr_monitor_tsv); then
        exec {lock_fd}>&-
        return 1
    fi

    while IFS=$'\t' read -r output description; do
        [[ -n $output ]] || continue
        outputs+=("$output")
    done <<< "$monitor_tsv"

    load_ddc_cache
    write_ddc_cache false "${outputs[@]}"
    exec {lock_fd}>&-
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
    local timeout_seconds=${2:-$VALUE_TIMEOUT_SECONDS}
    local terse

    terse=$(timeout "$timeout_seconds" ddcutil --bus "$bus" \
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
    local monitor_tsv output description device bus value current max percent label model serial index
    local -a outputs=()
    local -a descriptions=()

    exec 3>"$fifo"

    if ! monitor_tsv=$(get_hypr_monitor_tsv); then
        exec 3>&-
        return 1
    fi

    # Stream the internal panel immediately while Walker is opening.
    while IFS=$'\t' read -r output description; do
        [[ -n $output ]] || continue
        outputs+=("$output")
        descriptions+=("${description:-$output}")

        if [[ $output =~ ^(eDP|LVDS|DSI)- ]]; then
            if device=$(select_backlight_device) && value=$(read_sysfs_value "$device"); then
                read -r current max <<< "$value"
                percent=$(percent_for_value "$current" "$max")
                label="󰃠  ${description:-$output} (${output}): ${percent}%"
                append_menu_item "$state_file" "$output" sysfs "$device" - \
                    "$current" "$max" "$percent" "$label"
            fi
        fi
    done <<< "$monitor_tsv"

    # Validate the cached bus mapping, refreshing it only on a cache miss or
    # failed bus probe. This runs after Walker has opened its FIFO.
    if ! update_ddc_cache; then
        # Keep trying known mappings if detection itself failed. The cache
        # update leaves the on-disk cache untouched on a failed scan.
        load_ddc_cache
    fi

    for index in "${!outputs[@]}"; do
        output=${outputs[$index]}
        description=${descriptions[$index]}
        [[ $output =~ ^(eDP|LVDS|DSI)- ]] && continue
        bus=${DDC_BUS_BY_CONNECTOR[$output]:-}
        [[ $bus =~ ^[0-9]+$ ]] || continue
        value=${DDC_CURRENT_VALUE_BY_CONNECTOR[$output]:-}
        if [[ -z $value ]]; then
            value=$(read_ddc_value "$bus" "$CACHE_VALUE_TIMEOUT_SECONDS") || continue
        fi
        read -r current max <<< "$value"
        [[ $current =~ ^[0-9]+$ && $max =~ ^[1-9][0-9]*$ ]] || continue
        percent=$(percent_for_value "$current" "$max")
        model=${DDC_MODEL_BY_CONNECTOR[$output]:-$description}
        serial=${DDC_SERIAL_BY_CONNECTOR[$output]:-}
        [[ -n $serial ]] && model+=" (${serial})"
        label="󰍹  ${model} (${output}): ${percent}%"
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

show_menu() {
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

main() {
    case ${1:-menu} in
        menu)
            [[ $# -le 1 ]] || return 2
            show_menu
            ;;
        update-cache)
            [[ $# -eq 1 ]] || return 2
            update_ddc_cache
            ;;
        prune-cache)
            [[ $# -eq 1 ]] || return 2
            prune_ddc_cache
            ;;
        *)
            printf 'Usage: %s [menu|update-cache|prune-cache]\n' "${0##*/}" >&2
            return 2
            ;;
    esac
}

main "$@"
