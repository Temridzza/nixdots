# hosts/nixos.nix
{
  imports = [
    ../system/base.nix
    ../system/hardware.nix
    ../system/networking.nix
    ../system/users.nix
    ../system/bluetooth.nix

    ../features/hyprland.nix
    ../features/gaming.nix
    ../features/media.nix
    ../features/tor.nix
    ../features/app.nix
    ../features/dev.nix
    ../features/fonts.nix
    ../features/theme.nix
    ../features/byDpi/default.nix

    ../home/temridzza.nix
  ];
}