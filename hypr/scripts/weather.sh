
#!/bin/bash

# SETTINGS
APIKEY=$(cat $HOME/.owm-key)
CITY_NAME='Mascara'
COUNTRY_CODE='DZ'
LANG="en"
UNITS="metric"

# Catppuccin Mocha Colors
COLOR_CLOUD="#6c7086"
COLOR_THUNDER="#d3b987"
COLOR_LIGHT_RAIN="#73cef4"
COLOR_HEAVY_RAIN="#74c7ec"
COLOR_SNOW="#FFFFFF"
COLOR_FOG="#7f849c"
COLOR_TORNADO="#d3b987"
COLOR_SUN="#f9e2af"
COLOR_MOON="#FFFFFF"
COLOR_ERR="#f38ba8"
COLOR_WIND="#73cef4"
COLOR_COLD="#73cef4"        # Blue (≤10°C)
COLOR_HOT="#f38ba8"         # Red (≥30°C)
COLOR_NORMAL_TEMP="#fab387" # Orange (20-29°C)
COLOR_WHITE="#cdd6f4"

# Temperature Thresholds
HOT_TEMP=30
MID_TEMP=20
COLD_TEMP=10

# API Call
URL="https://api.openweathermap.org/data/2.5/weather?appid=$APIKEY&units=$UNITS&lang=$LANG&q=$(echo $CITY_NAME | sed 's/ /%20/g'),${COUNTRY_CODE}"
RESPONSE=$(curl -s $URL)

if [ -z "$RESPONSE" ] || [ "$(echo "$RESPONSE" | jq -r .cod)" != "200" ]; then
    echo "{ \"text\": \" Error\", \"tooltip\": \"Weather data unavailable\", \"class\": \"weather\", \"color\": \"${COLOR_ERR}\" }"
    exit 1
fi

# Extract Data
WID=$(echo "$RESPONSE" | jq -r .weather[0].id)
TEMP=$(echo "$RESPONSE" | jq -r .main.temp | awk '{print int($1)}')
TEMP_INT=$(echo "$TEMP" | awk '{printf "%.0f", $1}')  # Proper rounding
SUNRISE=$(echo "$RESPONSE" | jq -r .sys.sunrise)
SUNSET=$(echo "$RESPONSE" | jq -r .sys.sunset)
DATE=$(date +%s)

# Determine Weather Icon and Color
function setIcons {
    if [ "$WID" -le 232 ]; then
        ICON_COLOR=$COLOR_THUNDER; ICON="" # Thunderstorm
    elif [ "$WID" -le 321 ]; then
        ICON_COLOR=$COLOR_LIGHT_RAIN; ICON="" # Drizzle
    elif [ "$WID" -le 531 ]; then
        ICON_COLOR=$COLOR_HEAVY_RAIN; ICON="" # Rain
    elif [ "$WID" -le 622 ]; then
        ICON_COLOR=$COLOR_SNOW; ICON="" # Snow
    elif [ "$WID" -le 701 ]; then
        ICON_COLOR=$COLOR_FOG; ICON="" # Mist
    elif [ "$WID" -le 721 ]; then
        ICON_COLOR=$COLOR_FOG; ICON="" # Haze
    elif [ "$WID" -le 731 ]; then
        ICON_COLOR=$COLOR_FOG; ICON="" # Dust
    elif [ "$WID" -le 771 ]; then
        ICON_COLOR=$COLOR_FOG; ICON="" # Squalls
    elif [ "$WID" -eq 781 ]; then
        ICON_COLOR=$COLOR_TORNADO; ICON="" # Tornado
    elif [ "$WID" -eq 800 ]; then
        if [ "$DATE" -ge "$SUNRISE" ] && [ "$DATE" -le "$SUNSET" ]; then
            ICON_COLOR=$COLOR_SUN; ICON="" # Clear Day
        else
            ICON_COLOR=$COLOR_MOON; ICON="" # Clear Night
        fi
    elif [ "$WID" -eq 801 ]; then
        ICON_COLOR=$COLOR_CLOUD; ICON="" # Few Clouds
    elif [ "$WID" -eq 802 ]; then
        ICON_COLOR=$COLOR_CLOUD; ICON="" # Scattered Clouds
    elif [ "$WID" -eq 803 ]; then
        ICON_COLOR=$COLOR_CLOUD; ICON="" # Broken Clouds
    elif [ "$WID" -eq 804 ]; then
        ICON_COLOR=$COLOR_CLOUD; ICON="" # Overcast Clouds
    else
        ICON_COLOR=$COLOR_ERR; ICON="" # Unknown Condition
    fi
}

# Determine Temperature Color
function formatTemperature {
    if [ "$TEMP_INT" -le "$COLD_TEMP" ]; then
        TEMP_COLOR=$COLOR_COLD  # Blue for cold (≤10°C)
    elif [ "$TEMP_INT" -lt "$MID_TEMP" ]; then
        TEMP_COLOR=$COLOR_WHITE  # Neutral color for 11-19°C
    elif [ "$TEMP_INT" -lt "$HOT_TEMP" ]; then
        TEMP_COLOR=$COLOR_NORMAL_TEMP  # Orange for 20-29°C
    else
        TEMP_COLOR=$COLOR_HOT  # Red for hot (≥30°C)
    fi
    TEMP_ICON=""  # Thermometer icon
}

setIcons
formatTemperature

# Output JSON for Waybar with Pango Markup for colored meter icon
echo "{ \"text\": \"<span color='${ICON_COLOR}'>${ICON}</span> <span color='${TEMP_COLOR}'>${TEMP_ICON}</span> ${TEMP}°C\", \"tooltip\": \"Weather: ${ICON} ${TEMP}°C\", \"class\": \"weather\", \"color\": \"${COLOR_WHITE}\" }"

