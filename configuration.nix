{ config, lib, pkgs, inputs, ... }:
  let
    firefoxFirejailProfile = pkgs.writeText "firefox-firejail.profile" ''
      private-tmp
      env MOZ_ENABLE_WAYLAND=1
      caps.drop all
      disable-mnt
      machine-id
  '';
    qt6Full = pkgs.qt6.qtbase.overrideDerivation (old: {
    # tools = [ "all" ] включает все инструменты Qt6: syncqt, moc, uic и т.д.
    tools = [ "all" ]; 
  });
in
{
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "memlock"; value = "unlimited"; }
    { domain = "*"; type = "hard"; item = "memlock"; value = "unlimited"; }
  ];
  systemd.user.extraConfig = ''
    DefaultLimitMEMLOCK=infinity
  '';

  # =========================================================
  # 📦 Импорты: конфигурация железа + Home Manager
  # =========================================================
  imports = [
    ./hardware-configuration.nix
  ];

  # =========================================================
  # ⚙️ Базовые настройки системы
  # =========================================================
  system.stateVersion = "25.11"; # Версия NixOS, от которой считается совместимость

  nixpkgs.config = {
    allowUnfree = true; # Разрешаем проприетарные пакеты
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vscode"              # Microsoft VS Code
      "telegram-desktop"   # Telegram
    ];
  };

  services.udisks2.enable = true;


  # =========================================================
  # ♻️ Nix: автоочистка старых сборок (Garbage Collection)
  # =========================================================
  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;
      http-connections = 50;

      auto-optimise-store = true; # Удаляет дубликаты файлов в /nix/store (экономия места)
    };
      

    gc = {
      automatic = true;                 # Включить автоматический GC
      dates = "weekly";                 # Запуск раз в неделю
      options = "--delete-older-than 7d"; # Удалять сборки старше 7 дней
    };
  };

  # =========================================================
  # 🧠 Загрузчик и ядро
  # =========================================================
  boot = {
    loader.systemd-boot.enable = true;      # EFI загрузчик
    loader.efi.canTouchEfiVariables = true; # Разрешить запись в EFI
    kernelPackages = pkgs.linuxPackages; # Актуальное ядро Linux

    kernelParams = [
      "snd-intel-dspcfg.dsp_driver=1" # Фикс аудио для Intel
    ];
  };

  hardware.enableRedistributableFirmware = true; # Несвободные firmware

  # =========================================================
  # 🖥️ Графика и Wayland
  # =========================================================
  services.xserver = {
    enable = true;

    displayManager.startx.enable = true;

    desktopManager.lxqt.enable = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # Vulkan
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vulkan-loader
      vulkan-validation-layers
    ];
    extraPackages32 = with pkgs; [
      vulkan-loader
    ];
  };

  # Intel GPU
  services.xserver.videoDrivers = [ "modesetting" ];

  services.envfs.enable = true; # Совместимость с FHS путями

  # =========================================================
  # 🎧 Звук: PipeWire
  # =========================================================
  security.rtkit.enable = true; # Real-time приоритет для аудио

  services.pipewire = {
    enable = true;                # Аудио/видео сервер
    alsa.enable = true;           # Поддержка ALSA
    alsa.support32Bit = true;     # 32-бит звук (игры)
    pulse.enable = true;          # Совместимость с PulseAudio
    wireplumber.enable = true;    # Менеджер сессий
  };

  services.pulseaudio.enable = false; # PulseAudio отключён

  # =========================================================
  # 🔵 Bluetooth
  # =========================================================
  hardware.bluetooth = {
    enable = true;      # Bluetooth стек
    powerOnBoot = true; # Включать при старте
  };

  systemd.packages = [ pkgs.bluez ]; # Bluetooth daemon
  services.blueman.enable = true;    # GUI для Bluetooth

  # =========================================================
  # 🌐 Сеть
  # =========================================================
  
  # =========================================================
  # 🔒 waydroid
  # =========================================================

  # virtualisation.waydroid.enable = true;

  networking.nftables.enable = false;

  boot.kernelModules = [
    "binder_linux"
    "ashmem_linux"
  ];

  boot.extraModprobeConfig = ''
    options binder_linux devices=binder,hwbinder,vndbinder
  '';


  # =========================================================
  # 🔒 Firejail
  # =========================================================
  programs.firejail = {
    enable = true;
  };


  # =========================================================
  # 🌍 Локализация
  # =========================================================
  time.timeZone = "Europe/Moscow"; # Часовой пояс

  i18n = {
    defaultLocale = "en_US.UTF-8"; # Основная локаль
    supportedLocales = [
      "ru_RU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  console.useXkbConfig = true; # Раскладка как в графике

  # =========================================================
  # 👤 Пользователь
  # =========================================================

  

  

  # =========================================================
  # 🖋️ Шрифты
  # =========================================================
  fonts.packages = with pkgs; [
    dejavu_fonts
    fira-code
    fira-code-symbols
    font-awesome
    hackgen-nf-font
    ibm-plex
    inter
    jetbrains-mono
    material-icons
    maple-mono.NF
    minecraftia
    nerd-fonts.im-writing
    nerd-fonts.blex-mono
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-monochrome-emoji
    powerline-fonts
    roboto
    roboto-mono
    symbola
    terminus_font
    victor-mono
    liberation_ttf_v1
  ];

  # =========================================================
  # 🧰 Системные пакеты (с комментариями)
  # =========================================================
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
    btop        # Мониторинг ресурсов
    lsd         # Улучшенный ls
    fzf         # Интерактивный поиск
    xdg-user-dirs

    # docker
    # docker
    # docker-compose
    # lazydocker

    gnome-system-monitor
    xar
    udisks
    unrar
    zip
    python315
    macchanger
    

    # --- Wayland / Hyprland ---
    # swww        # Анимированные обои
    polkit_gnome

    mesa
    
    firejail
    iptables


    # --- Терминал ---
    kitty       # GPU терминал

    # --- Видео / Графика ---
    mesa        # OpenGL / Vulkan
    vulkan-tools# Vulkan диагностика
    imagemagick # Работа с изображениями
    

    # --- Звук ---
    alsa-utils  # ALSA утилиты
    pipewire    # Аудио сервер
    wireplumber # Менеджер PipeWire

    # --- Bluetooth ---
    bluez       # Bluetooth стек
    blueman     # GUI Bluetooth

    # --- Файлы ---
    thunar # Файловый менеджер
    xarchiver   # Архиватор
    unzip       # ZIP
    unrar       # RAR
    file-roller # GNOME архиватор

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
    
    liberation_ttf_v1

    # --- Уведомления ---
    libnotify               # Backend уведомлений
    notify notify-client    # CLI уведомления

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

    # --- Прочее ---
    wallust                 # Генерация цветовых схем
    brightnessctl           # Яркость
    yad                     # GUI диалоги из shell
    polkit                  # Управление правами
    kdePackages.polkit-kde-agent-1

    openssl
    ags

    opensnitch              #управление трафиком
    opensnitch-ui

    wget
    curl
    p7zip
    cabextract
    winetricks
    hyprland-qtutils

    # --- Программирование ---
    gcc
    cmake
    pkg-config

    qt6.qtbase
    qt5.qtbase

    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtmultimedia
    libsForQt5.qt5.qtconnectivity

    libsForQt5.qtbase
    libsForQt5.qtmultimedia
    libsForQt5.qtconnectivity

    qt5.qtmultimedia
    qt6.qtmultimedia
    qt5.qtconnectivity
    qt6.qtdeclarative
    
    curl
    gtest
    qt6.qttools
    qtcreator

    # для bydpi
    gnumake
    gcc

    # для LXQt
    lxqt.lxqt-session
    xinit
    xorgserver
    openbox

    # виртуализация с аппартаной поддержкой
    qemu
    virt-manager
    virt-viewer
    spice
    spice-gtk
    cdrkit
    
    insomnia # альтернатива postman

    privoxy  # перенаправление socks5 в http прокси для игр с поддержкой только http прокси (например, steam)
    socat    # сокеты для mpvpaper
  ];

  # services.privoxy = {
  #   enable = true;

  #   settings = {
  #     listen-address = "0.0.0.0:8118";

  #     forward-socks5 = "/ 127.0.0.1:9050 .";
  #   };
  # };

  # для virtualBox
  # virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;

  # для ambxst
  programs.gpu-screen-recorder.enable = true;

  # docker
  # virtualisation.docker.enable = true;
  # security.polkit.enable = true;

  # =========================================================
  # 📁 Thunar плагины
  # =========================================================
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      exo
      mousepad
      thunar-archive-plugin
      thunar-volman
      tumbler
    ];
  };

  # =========================================================
  # 🐚 jb и clion
  # =========================================================
  
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc

      # базовые
      zlib
      openssl
      fontconfig
      freetype
      dbus

      # X11 — КРИТИЧНО для AWT / Swing
      libx11
      libxext
      libxrender
      libxcursor
      libxrandr
      libXinerama
      libXi
      libXtst
      libXfixes
      libXdamage
      libXcomposite

      # графика
      libGL
      mesa

      # GTK (нужно CLion UI)
      gtk3
      glib
      pango
      cairo
      gdk-pixbuf

      # звук (иначе иногда падает)
      alsa-lib
      pulseaudio

    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # =========================================================
  # 🐚 Zsh
  # =========================================================
  programs.zsh.enable = true;

  # =========================================================
  # 🎨 Переменные окружения
  # =========================================================
  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Original-Classic"; # Тема курсора
    XCURSOR_SIZE = "24";                       # Размер курсора
    LXQT_WINDOW_MANAGER = "openbox";
  };

  # =========================================================
  # 🏠 Home Manager
  # =========================================================
}