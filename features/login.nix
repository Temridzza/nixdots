# features/login.nix
{ pkgs, ... }:
{
  services.xserver = {
    enable = true;

    displayManager.lightdm = {
      enable = true;
    };

    desktopManager.lxqt.enable = true;
  };

  programs.hyprland.enable = true;
}