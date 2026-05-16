# features/login.nix
{ pkgs, ... }:
{
  # services.xserver = {
  #   enable = true;

  #   displayManager.lightdm = {
  #     enable = true;
  #   };

  #   desktopManager.lxqt.enable = true;
  # };

  programs.silentSDDM = {
    enable = true;
    theme = "rei";  # можно поменять на любую тему из flake
    # settings = { ... }; # если нужны дополнительные настройки
  };

  programs.hyprland.enable = true;
}