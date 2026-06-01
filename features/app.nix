# system/app.nix
{ lib, pkgs, ... }:
let
    firefoxFirejailProfile = pkgs.writeText "firefox-firejail.profile" ''
      private-tmp
      env MOZ_ENABLE_WAYLAND=1
      caps.drop all
      disable-mnt
      machine-id
  '';
in
{
  environment.systemPackages = with pkgs; [
    # --- Пользовательские приложения ---
    firefox                 # Браузер
    telegram-desktop        # Мессенджер
    qbittorrent             # Торренты
    spotify                 # Музыка
    joplin-desktop          # Заметки
    onlyoffice-desktopeditors # Офис
    vscode                  # Редактор кода
    jetbrains-toolbox       # JetBrains IDE
    ncdu                    # просмотр диска
    rofi                    # менеджер приложений
    obs-studio              # запись
    networkmanagerapplet
    btop        # Мониторинг ресурсов

    sunshine                # подключение vita
    android-studio          # разработка андроид приложений
    filezilla               # передача по ftp
    waydroid                # эмулятор андроид
    kitty       # GPU терминал
    thunar # Файловый менеджер
    xarchiver   # Архиватор
    file-roller # GNOME архиватор
    rofi  # менеджер приложений

    # изолированные браузеры firefox
    (writeShellScriptBin "firefox-fj" ''
      mkdir -p $HOME/.firefox-fj
      exec firejail \
        --private=$HOME/.firefox-fj \
        --profile=${firefoxFirejailProfile} \
        ${pkgs.firefox}/bin/firefox "$@"
    '')

    gnome-system-monitor

    macchanger
    ags

    yandex-music
    yandex-cloud
  ];
  

  # =========================================================
  # 📁 Thunar плагины
  # =========================================================
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      exo
      mousepad
      thunar-archive-plugin
      thunar-volman
      tumbler
    ];
  };

  # для ambxst
  programs.gpu-screen-recorder.enable = true;
}