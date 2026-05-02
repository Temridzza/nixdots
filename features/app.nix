# system/app.nix
{ lib, pkgs ... }:
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

    sunshine                # подключение vita
    android-studio          # разработка андроид приложений
    filezilla               # передача по ftp
    waydroid                # эмулятор андроид

    # изолированные браузеры firefox
    (writeShellScriptBin "firefox-fj" ''
      mkdir -p $HOME/.firefox-fj
      exec firejail \
        --private=$HOME/.firefox-fj \
        --profile=${firefoxFirejailProfile} \
        ${pkgs.firefox}/bin/firefox "$@"
    '')
  ];
}