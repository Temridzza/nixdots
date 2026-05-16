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
    profileIcons = {
      temridzza = pkgs.path "/etc/nixos/home/temridzza/config/image/temridzza.jpg";
    };
  
    # settings = { ... }; # если нужны дополнительные настройки
  };

  programs.hyprland.enable = true;
}