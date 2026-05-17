#!/bin/bash
if command -v dunstctl &>/dev/null && [[ "$(dunstctl is-paused)" == "true" ]]; then
    printf '{"text":"󰂛","tooltip":"Do Not Disturb on","class":"active"}\n'
else
    printf '{"text":"","tooltip":"","class":""}\n'
fi
