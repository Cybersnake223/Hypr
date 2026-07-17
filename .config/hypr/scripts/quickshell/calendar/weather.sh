#!/usr/bin/env bash

export LC_NUMERIC=C

cache_dir="$HOME/.cache/quickshell/weather"
json_file="${cache_dir}/weather.json"
view_file="${cache_dir}/view_id"
daily_cache_file="${cache_dir}/daily_weather_cache.json"
next_day_cache_file="${cache_dir}/next_day_precache.json"
env_tracker_file="${cache_dir}/.env_tracker"
ENV_FILE="$(dirname "$0")/.env"

mkdir -p "${cache_dir}"

if [ -f "$ENV_FILE" ]; then
    set -a
    . "$ENV_FILE"
    set +a
fi

KEY="${OPENWEATHER_KEY:-}"
ID="${OPENWEATHER_CITY_ID:-}"
UNIT="${OPENWEATHER_UNIT:-metric}"

get_icon() {
    case "$1" in
        "50d"|"50n") echo "|Mist" ;;
        "01d") echo "|Sunny" ;;
        "01n") echo "|Clear" ;;
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") echo "|Cloudy" ;;
        "09d"|"09n"|"10d"|"10n") echo "|Rainy" ;;
        "11d"|"11n") echo "|Storm" ;;
        "13d"|"13n") echo "|Snow" ;;
        *) echo "|Unknown" ;;
    esac
}

get_hex() {
    case "$1" in
        "50d"|"50n") echo "#84afdb" ;;
        "01d") echo "#f9e2af" ;;
        "01n") echo "#cba6f7" ;;
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") echo "#bac2de" ;;
        "09d"|"09n"|"10d"|"10n") echo "#74c7ec" ;;
        "11d"|"11n") echo "#f9e2af" ;;
        "13d"|"13n") echo "#cdd6f4" ;;
        *) echo "#cdd6f4" ;;
    esac
}

write_dummy_data() {
    final_json="["
    for i in {0..4}; do
        future_date=$(date -d "+$i days" +%Y-%m-%d)
        f_day=$(date -d "$future_date" "+%a")
        f_full_day=$(date -d "$future_date" "+%A")
        f_date_num=$(date -d "$future_date" "+%d %b")

        final_json="${final_json}{
            \"id\": \"${i}\",
            \"day\": \"${f_day}\",
            \"day_full\": \"${f_full_day}\",
            \"date\": \"${f_date_num}\",
            \"max\": \"0.0\",
            \"min\": \"0.0\",
            \"feels_like\": \"0.0\",
            \"wind\": \"0\",
            \"humidity\": \"0\",
            \"pop\": \"0\",
            \"icon\": \"\",
            \"hex\": \"#cdd6f4\",
            \"desc\": \"No API Key\",
            \"hourly\": [{\"time\": \"00:00\", \"temp\": \"0.0\", \"icon\": \"\", \"hex\": \"#cdd6f4\"}]
        },"
    done
    final_json="${final_json%,}]"
    printf '{ "forecast": %s }\n' "$final_json" > "$json_file"
}

get_data() {
    if [[ -z "$KEY" || "$KEY" == "Skipped" || "$KEY" == "OPENWEATHER_KEY" ]]; then
        write_dummy_data
        return
    fi

    if [[ -z "$ID" ]]; then
        write_dummy_data
        return
    fi

    forecast_url="https://api.openweathermap.org/data/2.5/forecast?id=${ID}&units=${UNIT}&appid=${KEY}"
    raw_api=$(curl -fsS --connect-timeout 10 --max-time 20 "$forecast_url" 2>/dev/null)

    if [[ -z "$raw_api" ]]; then
        write_dummy_data
        return
    fi

    if ! echo "$raw_api" | jq -e . >/dev/null 2>&1; then
        write_dummy_data
        return
    fi

    api_cod=$(echo "$raw_api" | jq -r '.cod // empty')
    api_msg=$(echo "$raw_api" | jq -r '.message // empty')

    if [[ "$api_cod" == "401" ]] || [[ "$api_msg" == "Invalid API key."* ]]; then
        write_dummy_data
        return
    fi

    if [[ "$api_cod" != "200" ]]; then
        write_dummy_data
        return
    fi

    current_date=$(date +%Y-%m-%d)
    tomorrow_date=$(date -d "tomorrow" +%Y-%m-%d)

    if [ -f "$next_day_cache_file" ]; then
        precache_date=$(jq -r '.[0].dt_txt // empty' "$next_day_cache_file" 2>/dev/null | cut -d' ' -f1)
        if [ "$precache_date" = "$current_date" ]; then
            mv "$next_day_cache_file" "$daily_cache_file"
        fi
    fi

    api_today_items=$(echo "$raw_api" | jq -c ".list[] | select(.dt_txt | startswith(\"$current_date\"))" | jq -s '.')

    if [ -f "$daily_cache_file" ]; then
        cached_date=$(jq -r '.[0].dt_txt // empty' "$daily_cache_file" 2>/dev/null | cut -d' ' -f1)
        if [ "$cached_date" = "$current_date" ]; then
            merged_today=$(echo "$api_today_items" | jq --slurpfile cache "$daily_cache_file" \
                '($cache[0] + .) | unique_by(.dt) | sort_by(.dt)')
        else
            merged_today="$api_today_items"
        fi
    else
        merged_today="$api_today_items"
    fi

    echo "$merged_today" > "$daily_cache_file"

    api_tomorrow_items=$(echo "$raw_api" | jq -c ".list[] | select(.dt_txt | startswith(\"$tomorrow_date\"))" | jq -s '.')
    echo "$api_tomorrow_items" > "$next_day_cache_file"

    processed_forecast=$(echo "$raw_api" | jq --argjson today "$merged_today" --arg date "$current_date" \
        '.list = ($today + [.list[] | select(.dt_txt | startswith($date) | not)])')

    if [[ -z "$processed_forecast" ]]; then
        write_dummy_data
        return
    fi

    dates=$(echo "$processed_forecast" | jq -r '.list[].dt_txt | split(" ")[0]' | uniq | head -n 5)

    final_json="["
    counter=0

    for d in $dates; do
        day_data=$(echo "$processed_forecast" | jq "[.list[] | select(.dt_txt | startswith(\"$d\"))]")

        raw_max=$(echo "$day_data" | jq '[.[].main.temp_max] | max')
        f_max_temp=$(printf "%.1f" "$raw_max")

        raw_min=$(echo "$day_data" | jq '[.[].main.temp_min] | min')
        f_min_temp=$(printf "%.1f" "$raw_min")

        raw_feels=$(echo "$day_data" | jq '[.[].main.feels_like] | max')
        f_feels_like=$(printf "%.1f" "$raw_feels")

        f_pop=$(echo "$day_data" | jq '[.[].pop] | max // 0')
        f_pop_pct=$(awk "BEGIN { printf \"%d\", ($f_pop * 100) }")
        f_wind=$(echo "$day_data" | jq '[.[].wind.speed] | max | round')
        f_hum=$(echo "$day_data" | jq '[.[].main.humidity] | add / length | round')

        f_code=$(echo "$day_data" | jq -r '.[length/2 | floor].weather[0].icon')
        f_desc=$(echo "$day_data" | jq -r '.[length/2 | floor].weather[0].description' | sed -e "s/\b\(.\)/\u\1/g")
        f_icon=$(get_icon "$f_code" | cut -d'|' -f1)
        f_hex=$(get_hex "$f_code")

        f_day=$(date -d "$d" "+%a")
        f_full_day=$(date -d "$d" "+%A")
        f_date_num=$(date -d "$d" "+%d %b")

        hourly_json="["
        count_slots=$(echo "$day_data" | jq 'length - 1')

        for i in $(seq 0 1 "$count_slots"); do
            slot_item=$(echo "$day_data" | jq ".[$i]")

            raw_s_temp=$(echo "$slot_item" | jq ".main.temp")
            s_temp=$(printf "%.1f" "$raw_s_temp")

            s_dt=$(echo "$slot_item" | jq ".dt")
            s_time=$(date -d @"$s_dt" "+%H:%M")
            s_code=$(echo "$slot_item" | jq -r ".weather[0].icon")
            s_hex=$(get_hex "$s_code")
            s_icon=$(get_icon "$s_code" | cut -d'|' -f1)

            hourly_json="${hourly_json}{\"time\": \"${s_time}\", \"temp\": \"${s_temp}\", \"icon\": \"${s_icon}\", \"hex\": \"${s_hex}\"},"
        done
        hourly_json="${hourly_json%,}]"

        final_json="${final_json}{
            \"id\": \"${counter}\",
            \"day\": \"${f_day}\",
            \"day_full\": \"${f_full_day}\",
            \"date\": \"${f_date_num}\",
            \"max\": \"${f_max_temp}\",
            \"min\": \"${f_min_temp}\",
            \"feels_like\": \"${f_feels_like}\",
            \"wind\": \"${f_wind}\",
            \"humidity\": \"${f_hum}\",
            \"pop\": \"${f_pop_pct}\",
            \"icon\": \"${f_icon}\",
            \"hex\": \"${f_hex}\",
            \"desc\": \"${f_desc}\",
            \"hourly\": ${hourly_json}
        },"
        ((counter++))
    done

    final_json="${final_json%,}]"
    printf '{ "forecast": %s }\n' "$final_json" > "$json_file"
}

if [[ "$1" == "--getdata" ]]; then
    get_data

elif [[ "$1" == "--json" ]]; then
    CACHE_LIMIT=900
    PENDING_RETRY_LIMIT=3600

    env_changed=0
    if [ -f "$ENV_FILE" ]; then
        env_mtime=$(stat -c %Y "$ENV_FILE")
        last_env_mtime=$(cat "$env_tracker_file" 2>/dev/null || echo "0")

        if [ "$env_mtime" -gt "$last_env_mtime" ]; then
            env_changed=1
            echo "$env_mtime" > "$env_tracker_file"
        fi
    fi

    if [ -f "$json_file" ]; then
        file_time=$(stat -c %Y "$json_file")
        current_time=$(date +%s)
        diff=$((current_time - file_time))

        if [ "$env_changed" -eq 1 ]; then
            touch "$json_file"
            get_data &
        elif grep -q '"desc": "No API Key"' "$json_file"; then
            if [ "$diff" -gt "$PENDING_RETRY_LIMIT" ]; then
                touch "$json_file"
                get_data &
            fi
        else
            if [ "$diff" -gt "$CACHE_LIMIT" ]; then
                touch "$json_file"
                get_data &
            fi
        fi
        cat "$json_file"
    else
        get_data
        cat "$json_file"
    fi

elif [[ "$1" == "--view-listener" ]]; then
    [ -f "$view_file" ] || echo "0" > "$view_file"
    tail -F "$view_file"

elif [[ "$1" == "--nav" ]]; then
    [ -f "$view_file" ] || echo "0" > "$view_file"
    current=$(cat "$view_file")
    direction=$2
    max_idx=4

    if [[ "$direction" == "next" && "$current" -lt "$max_idx" ]]; then
        echo $((current + 1)) > "$view_file"
    elif [[ "$direction" == "prev" && "$current" -gt 0 ]]; then
        echo $((current - 1)) > "$view_file"
    fi

elif [[ "$1" == "--icon" ]]; then
    jq -r '.forecast[0].icon' "$json_file"

elif [[ "$1" == "--temp" ]]; then
    t=$(jq -r '.forecast[0].max' "$json_file")
    echo "${t}°C"

elif [[ "$1" == "--hex" ]]; then
    jq -r '.forecast[0].hex' "$json_file"

elif [[ "$1" == "--current-icon" ]]; then
    curr_time=$(date +%H:%M)
    jq -r --arg ct "$curr_time" '(.forecast[0].hourly | map(select(.time <= $ct)) | last) // .forecast[0].hourly[0] | .icon' "$json_file"

elif [[ "$1" == "--current-temp" ]]; then
    curr_time=$(date +%H:%M)
    t=$(jq -r --arg ct "$curr_time" '(.forecast[0].hourly | map(select(.time <= $ct)) | last) // .forecast[0].hourly[0] | .temp' "$json_file")
    echo "${t}°C"

elif [[ "$1" == "--current-hex" ]]; then
    curr_time=$(date +%H:%M)
    jq -r --arg ct "$curr_time" '(.forecast[0].hourly | map(select(.time <= $ct)) | last) // .forecast[0].hourly[0] | .hex' "$json_file"

elif [[ "$1" == "--quick-island" ]]; then
    if [ -f "$json_file" ]; then
        curr_time=$(date +%H:%M)
        icon=$(jq -r --arg ct "$curr_time" '(.forecast[0].hourly | map(select(.time <= $ct)) | last) // .forecast[0].hourly[0] | .icon' "$json_file")
        temp=$(jq -r --arg ct "$curr_time" '(.forecast[0].hourly | map(select(.time <= $ct)) | last) // .forecast[0].hourly[0] | .temp' "$json_file")
        echo "${icon}|${temp}°"
    else
        echo "|--°"
    fi
fi
