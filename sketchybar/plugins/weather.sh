#!/bin/bash

# Fetch weather data cleanly from wttr.in in JSON format
WEATHER_INFO=$(curl -s "wttr.in/?format=j1")

if [ -n "$WEATHER_INFO" ]; then
  CONDITION=$(echo "$WEATHER_INFO" | jq -r '.current_condition[0].weatherDesc[0].value')
  TEMP=$(echo "$WEATHER_INFO" | jq -r '.current_condition[0].temp_C')
  
  sketchybar --set $NAME label="${TEMP}°C • ${CONDITION}"
else
  sketchybar --set $NAME label="Weather Unavailable"
fi
