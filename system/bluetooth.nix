# system/bluetooth.nix
{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    blueman
  ];

  systemd.user.services.blueman-applet.serviceConfig.ExecStart = [
    ""
    "${pkgs.blueman}/bin/blueman-applet"
  ];
}