#!/bin/bash
# Amsterdam weather from Open-Meteo (no API key). One line:
# code|temp|hi|lo|desc-less fields, then 3x (day|code|hi|lo) for the next days.
curl -sf --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=52.37&longitude=4.89&current=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=4" |
jq -r '
  def r: . + 0.5 | floor;
  [.current.weather_code, (.current.temperature_2m|r), (.daily.temperature_2m_max[0]|r), (.daily.temperature_2m_min[0]|r)]
  + [range(1;4) as $i | (.daily.time[$i] | strptime("%Y-%m-%d") | mktime | strftime("%a")),
     .daily.weather_code[$i], (.daily.temperature_2m_max[$i]|r), (.daily.temperature_2m_min[$i]|r)]
  | map(tostring) | join("|")'
