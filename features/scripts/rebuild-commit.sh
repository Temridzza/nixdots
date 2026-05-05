#!/usr/bin/env bash

set -e

cd /etc/nixos

# rebuild
nix run .#switch

# notify
notify-send "NixOS" "Rebuild complete ✔"