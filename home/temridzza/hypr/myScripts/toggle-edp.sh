#!/bin/bash

MONITOR="eDP-1"
STATE_FILE="/tmp/hypr_edp_state"

# Функция: выключить монитор
disable_monitor() {
    hyprctl keyword monitor "$MONITOR,disable"
    echo "off" > "$STATE_FILE"
}

# Функция: включить монитор
enable_monitor() {
    # Настрой разрешение, позицию и scale под своё железо
    hyprctl keyword monitor "$MONITOR,1920x1080@60,0x0,1"
    echo "on" > "$STATE_FILE"
}

# Проверка состояния из временного файла
if [[ -f "$STATE_FILE" ]]; then
    STATE=$(cat "$STATE_FILE")
else
    STATE="on"
fi

if [[ "$STATE" == "on" ]]; then
    disable_monitor
else
    enable_monitor
fi
