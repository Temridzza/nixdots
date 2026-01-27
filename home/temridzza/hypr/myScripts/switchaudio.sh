#!/usr/bin/env bash
# switchaudio — NixOS
# pw | pa | status

set -e

RUNTIME_DIR="${XDG_RUNTIME_DIR}"

current_backend() {
  pactl info 2>/dev/null | grep -q "PulseAudio (on PipeWire" && echo pipe && return
  pactl info 2>/dev/null | grep -q "Server Name: pulseaudio" && echo pulse && return
  echo none
}

stop_pipewire() {
  systemctl --user stop wireplumber.service || true
  systemctl --user stop pipewire.service pipewire.socket || true
  systemctl --user stop pipewire-pulse.service pipewire-pulse.socket || true
  systemctl --user mask pipewire-pulse.socket || true
}

stop_pulse() {
  systemctl --user stop pulseaudio.service pulseaudio.socket || true
}

clean_runtime() {
  rm -f "$RUNTIME_DIR/pulse/native"
}

enable_pipewire() {
  echo "🎧 Включение PipeWire"
  stop_pulse
  systemctl --user unmask pipewire-pulse.socket
  systemctl --user start pipewire.socket
  systemctl --user start pipewire.service
  systemctl --user start wireplumber.service
  systemctl --user start pipewire-pulse.socket
  systemctl --user start pipewire-pulse.service
}

enable_pulse() {
  echo "🔊 Включение PulseAudio"
  stop_pipewire
  clean_runtime

  # КЛЮЧЕВОЕ ОТЛИЧИЕ ОТ ARCH
  env -u PULSE_SERVER -u PULSE_RUNTIME_PATH \
    systemctl --user start pulseaudio.socket

  env -u PULSE_SERVER -u PULSE_RUNTIME_PATH \
    systemctl --user start pulseaudio.service
}

show_status() {
  echo "🔎 Backend: $(current_backend)"
  pactl info || true
}

case "$1" in
  pw)
    [[ "$(current_backend)" == "pipe" ]] && echo "ℹ️ Уже PipeWire" && exit 0
    enable_pipewire
    show_status
    ;;
  pa)
    [[ "$(current_backend)" == "pulse" ]] && echo "ℹ️ Уже PulseAudio" && exit 0
    enable_pulse
    show_status
    ;;
  status)
    show_status
    ;;
  *)
    echo "Использование: $0 {pw|pa|status}"
    exit 1
    ;;
esac
