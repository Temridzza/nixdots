#!/bin/bash
# Rofi search: browser select + search entry

config_file="$HOME/.config/hypr/UserConfigs/01-UserDefaults.conf"
[[ ! -f "$config_file" ]] && exit 1

# Hyprland → bash
config_content=$(sed 's/\$//g; s/ = /=/' "$config_file")
eval "$config_content"
[[ -z "$Search_Engine" ]] && exit 1

# Темы
rofi_search="$HOME/.config/rofi/config-search.rasi"
rofi_default="$HOME/.config/rofi/config.rasi"

# 1️⃣ Выбор браузера (НОРМАЛЬНЫЙ rofi)
browser=$(printf "Firefox\nTor Browser" | rofi -dmenu \
    -config "$rofi_default" \
    -p "Browser")

[[ -z "$browser" ]] && exit 0

# 2️⃣ Ввод запроса (ТВОЯ search-тема)
query=$(rofi -dmenu \
    -config "$rofi_search")

[[ -z "$query" ]] && exit 0

url="${Search_Engine}${query}"

# 3️⃣ Запуск
case "$browser" in
    "Firefox")
        firefox "$url"
        ;;
    "Tor Browser")
        tor-browser "$url"
        ;;
esac
