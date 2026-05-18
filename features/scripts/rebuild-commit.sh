#!/usr/bin/env bash

set -e

cd /etc/nixos

MODE="${1:-switch}"

case "$MODE" in
  switch)
    nix run .#switch
    notify-send "NixOS" "Switch complete ✔"
    ;;

  boot)
    nix run .#boot
    notify-send "NixOS" "Boot rebuild complete ✔"
    ;;

  help)
    echo "Usage:"
    echo "  rebuild           -> nixos-rebuild switch"
    echo "  rebuild switch    -> nixos-rebuild switch"
    echo "  rebuild boot      -> nixos-rebuild boot"
    echo "  rebuild help      -> show this help"
    ;;

  *)
    echo "Unknown option: $MODE"
    echo "Use: rebuild help"
    exit 1
    ;;
esac