# system/bluetooth.nix
{ pkgs, ... }:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    bluez       # Bluetooth стек
    blueman     # GUI Bluetooth
  ];
}