#!/usr/bin/env bash

set -e

cd /etc/nixos

# add
git add .

# ask commit message
echo -n "Commit message: "
read msg

# commit
git commit -m "$msg"

# rebuild
sudo nixos-rebuild switch --flake /etc/nixos#nixos

# notify
notify-send "NixOS" "Rebuild complete ✔"