# system/base.nix
{ lib, pkgs, ... }:
let
  commit = self.rev or "dirty";
in 
{
  system.stateVersion = "25.11"; # Версия NixOS, от которой считается совместимость

  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "memlock"; value = "unlimited"; }
    { domain = "*"; type = "hard"; item = "memlock"; value = "unlimited"; }
  ];

  systemd.user.extraConfig = ''
    DefaultLimitMEMLOCK=infinity
  '';

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vscode"
      "telegram-desktop"
    ];
  };

  # =========================================================
  # ♻️ Nix: автоочистка старых сборок (Garbage Collection)
  # =========================================================
  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;
      http-connections = 50;
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  # ограничение сборок
  boot.loader.systemd-boot.configurationLimit = 10;
  
  # добавление описания сборки прямо из коммита
  system.nixos.label = "nixos-${commit}";


  # ==========================================================

  services.envfs.enable = true;

  time.timeZone = "Europe/Moscow";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "ru_RU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  console.useXkbConfig = true;

  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Original-Classic";
    XCURSOR_SIZE = "24";
  };

  environment.systemPackages = with pkgs; [

    # --- Базовые CLI утилиты ---
    bash        # Командная оболочка
    coreutils   # ls, cp, mv, rm
    findutils   # find, xargs
    gawk        # Обработка текста
    gnused      # Потоковый редактор
    procps      # ps, top
    bc          # Консольный калькулятор
    jq          # Работа с JSON
    git         # Контроль версий
    fastfetch   # Информация о системе
    lsd         # Улучшенный ls
    fzf         # Интерактивный поиск
    xdg-user-dirs
    xar
    udisks
    unrar
    zip
    curl
    p7zip
    wget
    unzip

    # --- Видео / Графика ---
    mesa        # OpenGL / Vulkan
    vulkan-tools# Vulkan диагностика
    imagemagick # Работа с изображениями

    # --- Прочее ---
    wallust                 # Генерация цветовых схем
    brightnessctl           # Яркость
    yad                     # GUI диалоги из shell
    polkit                  # Управление правами
    kdePackages.polkit-kde-agent-1

    # --- Уведомления ---
    libnotify               # Backend уведомлений
    notify notify-client    # CLI уведомления

    # --- Звук ---
    alsa-utils  # ALSA утилиты
    pipewire    # Аудио сервер
    wireplumber # Менеджер PipeWire
    socat    # сокеты для mpvpaper

    polkit_gnome
  ];
  services.udisks2.enable = true;
  programs.zsh.enable = true;
}