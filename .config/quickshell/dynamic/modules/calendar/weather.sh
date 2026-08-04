#!/usr/bin/env bash

# Force standard C locale for number formatting (fixes printf decimal/comma issues on varying OS locales)
export LC_NUMERIC=C

# Paths
cache_dir="$HOME/.cache/quickshell/weather"
json_file="${cache_dir}/weather.json"
daily_cache_file="${cache_dir}/daily_weather_cache.json"
next_day_cache_file="${cache_dir}/next_day_precache.json"
# Source secrets from central location first, fallback to old path
if [ -f "$HOME/.config/quickshell/secrets/weather.env" ]; then
    ENV_FILE="$HOME/.config/quickshell/secrets/weather.env"
else
    ENV_FILE="$HOME/.config/quickshell/dynamic/modules/calendar/.env"
fi

# API Settings
# Load environment variables silently
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

# API Settings from .env
KEY="$OPENWEATHER_KEY"
ID="$OPENWEATHER_CITY_ID"
UNIT="${OPENWEATHER_UNIT:-metric}" # Default to metric if not set

mkdir -p "${cache_dir}"

get_icon() {
    case $1 in
        "50d"|"50n") icon=""; quote="Mist" ;;
        "01d") icon=""; quote="Sunny" ;;
        "01n") icon=""; quote="Clear" ;;
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") icon=""; quote="Cloudy" ;;
        "09d"|"09n"|"10d"|"10n") icon=""; quote="Rainy" ;;
        "11d"|"11n") icon=""; quote="Storm" ;;
        "13d"|"13n") icon=""; quote="Snow" ;;
        *) icon=""; quote="Unknown" ;;
    esac
    echo "$icon|$quote"
}

get_hex() {
    case $1 in
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
        future_date=$(date -d "+$i days")
        f_day=$(date -d "$future_date" "+%a")
        f_full_day=$(date -d "$future_date" "+%A")
        f_date_num=$(date -d "$future_date" "+%d %b")
        
        final_json="${final_json} {
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
            \"unit\": \"°C\",
            \"hourly\": [{\"time\": \"00:00\", \"temp\": \"0.0\", \"icon\": \"\", \"hex\": \"#cdd6f4\"}]
        },"
    done
    final_json="${final_json%,}]"
    echo "{ \"forecast\": ${final_json} }" > "${json_file}"
}

get_data() {
    # ---------------------------------------------------------
    # DUMMY DATA FALLBACK (If API key is missing or skipped)
    # ---------------------------------------------------------
    if [[ -z "$KEY" || "$KEY" == "Skipped" || "$KEY" == "OPENWEATHER_KEY" ]]; then
        write_dummy_data
        return
    fi

    # ---------------------------------------------------------
    # STANDARD API FETCH LOGIC
    # ---------------------------------------------------------
    forecast_url="http://api.openweathermap.org/data/2.5/forecast?APPID=${KEY}&id=${ID}&units=${UNIT}"
    raw_api=$(curl -sf --max-time 15 "$forecast_url")
    
    # Check if curl failed OR if OpenWeather returned an error (like 401 for pending keys)
    api_cod=$(echo "$raw_api" | jq -r '.cod' 2>/dev/null)
    
    if [ -z "$raw_api" ] || [[ "$api_cod" != "200" ]]; then
        write_dummy_data
        return
    fi

    current_date=$(date +%Y-%m-%d)
    tomorrow_date=$(date -d "tomorrow" +%Y-%m-%d)

    # 1. ROLLOVER CHECK
    if [ -f "$next_day_cache_file" ]; then
        precache_date=$(cat "$next_day_cache_file" | jq -r '.[0].dt_txt' | cut -d' ' -f1)
        if [ "$precache_date" == "$current_date" ]; then
            mv "$next_day_cache_file" "$daily_cache_file"
        fi
    fi

    # 2. PROCESS TODAY
    api_today_items=$(echo "$raw_api" | jq -c ".list[] | select(.dt_txt | startswith(\"$current_date\"))" | jq -s '.')

    if [ -f "$daily_cache_file" ]; then
        cached_date=$(cat "$daily_cache_file" | jq -r '.[0].dt_txt' | cut -d' ' -f1)
        if [ "$cached_date" == "$current_date" ]; then
            merged_today=$(echo "$api_today_items" | jq --slurpfile cache "$daily_cache_file" \
                '($cache[0] + .) | unique_by(.dt) | sort_by(.dt)')
        else
            merged_today="$api_today_items"
        fi
    else
        merged_today="$api_today_items"
    fi

    echo "$merged_today" > "$daily_cache_file"

    # 3. PRE-CACHE TOMORROW
    api_tomorrow_items=$(echo "$raw_api" | jq -c ".list[] | select(.dt_txt | startswith(\"$tomorrow_date\"))" | jq -s '.')
    echo "$api_tomorrow_items" > "$next_day_cache_file"

    # 4. BUILD FINAL JSON
    processed_forecast=$(echo "$raw_api" | jq --argjson today "$merged_today" --arg date "$current_date" \
        '.list = ($today + [.list[] | select(.dt_txt | startswith($date) | not)])')

    if [ ! -z "$processed_forecast" ]; then
        dates=$(echo "$processed_forecast" | jq -r '.list[].dt_txt | split(" ")[0]' | uniq | head -n 5)
        
        final_json="["
        counter=0
        
        for d in $dates; do
            day_data=$(echo "$processed_forecast" | jq "[.list[] | select(.dt_txt | startswith(\"$d\"))]")
            IFS=$'\t' read -r raw_max raw_min raw_feels f_pop_raw f_wind f_hum f_code f_desc <<< $(
                echo "$day_data" | jq -r --arg d "$d" '
                    . as $day
                    | [$day[].main.temp_max] | max as $max
                    | [$day[].main.temp_min] | min as $min
                    | [$day[].main.feels_like] | max as $feels
                    | [$day[].pop] | max as $pop
                    | ([$day[].wind.speed] | max | round) as $wind
                    | ([$day[].main.humidity] | add / length | round) as $hum
                    | ($day[(($day | length) / 2) | floor].weather[0].icon) as $code
                    | ($day[(($day | length) / 2) | floor].weather[0].description) as $desc
                    | [$max, $min, $feels, $pop, $wind, $hum, $code, $desc]
                    | @tsv'
            )
            f_max_temp=$(printf "%.1f" "$raw_max")
            f_min_temp=$(printf "%.1f" "$raw_min")
            f_feels_like=$(printf "%.1f" "$raw_feels")
            f_pop_pct=$(echo "$f_pop_raw * 100" | bc | cut -d. -f1)
            f_icon_data=$(get_icon "$f_code")
            f_icon=$(echo "$f_icon_data" | cut -d'|' -f1)
            f_hex=$(get_hex "$f_code")
            
            f_day=$(date -d "$d" "+%a")
            f_full_day=$(date -d "$d" "+%A")
            f_date_num=$(date -d "$d" "+%d %b")

            hourly_json="["
            count_slots=$(echo "$day_data" | jq '. | length')
            count_slots=$((count_slots-1))
            
            for i in $(seq 0 1 $count_slots); do
                slot_item=$(echo "$day_data" | jq ".[$i]")
                
                raw_s_temp=$(echo "$slot_item" | jq ".main.temp")
                s_temp=$(printf "%.1f" "$raw_s_temp")
                
                s_dt=$(echo "$slot_item" | jq ".dt")
                s_time=$(date -d @$s_dt "+%H:%M")
                s_code=$(echo "$slot_item" | jq -r ".weather[0].icon")
                s_hex=$(get_hex "$s_code")
                s_icon=$(get_icon "$s_code" | cut -d'|' -f1)
                
                hourly_json="${hourly_json} {\"time\": \"${s_time}\", \"temp\": \"${s_temp}\", \"icon\": \"${s_icon}\", \"hex\": \"${s_hex}\"},"
            done
            hourly_json="${hourly_json%,}]"

            final_json="${final_json} {
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
                \"unit\": \"$([[ "$UNIT" == "imperial" ]] && echo "°F" || echo "°C")\",
                \"hourly\": ${hourly_json}
            },"
            ((counter++))
        done
        final_json="${final_json%,}]"

        echo "{ \"forecast\": ${final_json} }" > "${json_file}"
    fi
}

# --- MODE HANDLING ---
if [[ "$1" == "--island" ]]; then
    # Single combined call: refresh cache once if missing/stale, then emit all
    # 12 fields the island expects in one jq pass over the cached JSON.
    # Fields: icon, desc, max, min, feels, humidity, wind, pop, hex, unit, curIcon, curTemp
    if [ -f "$json_file" ]; then
        file_time=$(stat -c %Y "$json_file")
        current_time=$(date +%s)
        diff=$((current_time - file_time))
        if [ "$diff" -gt 900 ]; then
            touch "$json_file"
            get_data &
        fi
    else
        get_data
    fi

    curr_time=$(date +%H:%M)
    cat "$json_file" 2>/dev/null | jq -r --arg ct "$curr_time" '
        .forecast[0] as $f
        | ($f.hourly) as $h
        | ($h[0].time) as $first
        | (if $ct < $first then $h[-1]
           else ($h[0:-1] | map(select(.time <= $ct)) | last) // $h[0]
           end) as $cur
        | [$f.icon, $f.desc, $f.max, $f.min, $f.feels_like, $f.humidity, $f.wind, $f.pop, $f.hex, $f.unit, $cur.icon, ($cur.temp + $f.unit)] | @tsv'
fi
