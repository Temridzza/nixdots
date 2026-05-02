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
  systemd.packages = [ pkgs.bluez ]; # Bluetooth daemon
}