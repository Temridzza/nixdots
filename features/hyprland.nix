# features/hyprland.nix
{ pkgs, inputs, ... }:
{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  programs.xwayland.enable = true;

  xdg.portal.enable = true;

  environment.systemPackages = with pkgs; [
    wayland                       # Протокол отображения
    wlroots                       # Библиотека композиторов
    waybar                        # Панель
    rofi  # менеджер приложений
    wl-clipboard  # Буфер обмена Wayland
    cliphist #
    grim  #
    slurp #
    swappy  #
    hypridle  #
    hyprshot  #
    hyprcursor#
    wlogout # Меню выхода
    swaybg  # Обои
    mpvpaper  # Видео-обои
    nwg-look  #
    nwg-displays#
    hyprprop  # Инспектор окон
    hyprpolkitagent#
    pyprland  #
    hyprlang  #
    waypaper  #
    hyprland-qt-support #
    hyprland-qtutils
  ];
}