# system/theme.nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # --- Темы / GTK / Qt ---
    gtk2 gtk3 gtk4         # GTK библиотеки
    adw-gtk3               # libadwaita стиль
    catppuccin-gtk         # GTK тема
    papirus-icon-theme     # Иконки
    bibata-cursors         # Курсоры
    nwg-look                # GTK настройки
    libsForQt5.qt5ct        # Qt5 настройки
    qt6Packages.qt6ct       # Qt6 настройки
    libsForQt5.qtstyleplugin-kvantum # Kvantum Qt5
    qt6Packages.qtstyleplugin-kvantum# Kvantum Qt6
    catppuccin-kvantum      # Kvantum тема
    glib                    # База GTK
  ];
}