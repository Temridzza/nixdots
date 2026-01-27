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

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

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
    kernelPackages = pkgs.linuxPackages_latest; # Актуальное ядро Linux

    kernelParams = [
      "snd-intel-dspcfg.dsp_driver=1" # Фикс аудио для Intel
    ];
  };

  hardware.enableRedistributableFirmware = true; # Несвободные firmware

  # =========================================================
  # 🖥️ Графика и Wayland
  # =========================================================
  services.xserver.enable = false; # Полный отказ от X11

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

  # XWayland (обязательно!)
  programs.xwayland.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  services.envfs.enable = true; # Совместимость с FHS путями

  xdg.portal = {
    enable = true; # Порталы для sandbox приложений
    # extraPortals = with pkgs; [
    #   xdg-desktop-portal-hyprland # Портал для Hyprland
    # ];
  };

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
  networking = {
    hostName = "nixos";                 # Имя хоста
    networkmanager.enable = true;       # Управление сетью
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 2222 ];
  };


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
  users.users.temridzza = {
    isNormalUser = true;
    shell = pkgs.zsh; # Основная оболочка

    extraGroups = [
      "wheel"          # sudo
      "networkmanager"# сеть
      "audio"          # звук
      "video"          # видео
      "input"          # устройства ввода
      "tty"
      "uinput"
      "bluetooth"
      "docker"
      "tor"
    ];

    packages = with pkgs; [
      tree # Отображение структуры каталогов
    ];
  };

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
    slurp
    grim
    swappy
    xdg-user-dirs
    docker
    obfs4
    gnome-system-monitor
    xar
    traceroute
    cava

    # --- Wayland / Hyprland ---
    # hyprland    # Wayland WM
    wayland     # Протокол отображения
    wlroots     # Библиотека композиторов
    wl-clipboard# Буфер обмена Wayland
    cliphist
    waybar      # Панель
    hyprprop    # Инспектор окон
    swaybg      # Обои
    swww        # Анимированные обои
    mpvpaper    # Видео-обои
    wlogout     # Меню выхода
    hypridle
    hyprpolkitagent
    polkit_gnome
    pyprland
    hyprlang
    hyprshot
    hyprcursor
    mesa
    nwg-displays
    nwg-look
    waypaper
    hyprland-qt-support
    firejail

    # --- Терминал ---
    kitty       # GPU терминал

    # --- Видео / Графика ---
    mesa        # OpenGL / Vulkan
    vulkan-tools# Vulkan диагностика
    ffmpeg      # Работа с видео/аудио
    imagemagick # Работа с изображениями
    mpv         # Видеоплеер
    obs-studio  # Запись экрана

    # --- Звук ---
    alsa-utils  # ALSA утилиты
    pavucontrol # GUI микшер
    pamixer     # CLI микшер
    pipewire    # Аудио сервер
    wireplumber # Менеджер PipeWire

    # --- Bluetooth ---
    bluez       # Bluetooth стек
    blueman     # GUI Bluetooth

    # --- Файлы ---
    xfce.thunar # Файловый менеджер
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
    swaynotificationcenter  # Notification center

    # --- Пользовательские приложения ---
    firefox                 # Браузер
    telegram-desktop        # Мессенджер
    qbittorrent             # Торренты
    spotify                 # Музыка
    joplin-desktop          # Заметки
    onlyoffice-desktopeditors # Офис
    vscode                  # Редактор кода
    jetbrains-toolbox       # JetBrains IDE
    drawio                  # Диаграммы
    heroic                  # Epic/GOG launcher
    steam                   # Игры + Proton
    ppsspp                  # PSP эмулятор
    rpcs3                   # PS3 эмулятор
    rofi
    gitlab
    thunderbird
    geary
    obs-studio
    libreoffice
    networkmanagerapplet
    gamescope
    tor-browser

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
    tor
    torsocks
    openssl
    ags

    steam-run
    wget
    curl
    p7zip
    cabextract
    winetricks
    openbox
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
    qt5.qtconnectivity

    curl
    gtest
    qt6.qttools
    qtcreator
  ];
  #virtualisation.docker.enable = true;
  security.polkit.enable = true;


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
  # 🐚 jb и clino
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
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXinerama
      xorg.libXi
      xorg.libXtst
      xorg.libXfixes
      xorg.libXdamage
      xorg.libXcomposite

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
  };

  # =========================================================
  # 🏠 Home Manager
  # =========================================================
  
  home-manager.users.temridzza = { lib, ... }: {
    home.stateVersion = "24.05";

    # extraSpecialArgs = {
    #   inherit inputs;
    # };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    # 👉 Симлинк ~/.config/hypr → /etc/nixos/home/temridzza/hypr
    xdg.configFile."hypr".source = ./home/temridzza/hypr;
    xdg.configFile = {
      "cava".source    = ./home/temridzza/config/cava;
      "waybar".source  = ./home/temridzza/config/waybar;
      "rofi".source    = ./home/temridzza/config/rofi;
      "kitty".source   = ./home/temridzza/config/kitty;
      "wallust".source = ./home/temridzza/config/wallust;
      "wlogout".source = ./home/temridzza/config/wlogout;
      "btop".source = ./home/temridzza/config/btop;
      "fastfetch".source = ./home/temridzza/config/fastfetch;
      "swaync".source = ./home/temridzza/config/swaync;
      "swappy".source = ./home/temridzza/config/swappy;
    };

    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "half-life";
        plugins = [ "git" "sudo" "extract" ];
      };

      # === ПЛАГИНЫ (аналог zsh-autosuggestions и т.д.) ===
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

      # === АЛИАСЫ (lsd, clear, reload) ===
      shellAliases = {
        ls   = "lsd";
        l    = "ls -l";
        la   = "ls -a";
        lla  = "ls -la";
        lt   = "ls --tree";
        c    = "clear";
        reload = "source ~/.zshrc";

        # ✅ Flake-only workflow
        rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos && notify-send 'nixos' 'rebuild ready'";
        update  = "cd /etc/nixos && nix flake update && rebuild";

        # ❌ Блокировка legacy-путей
        nixos-rebuild = "echo '❌ Use: rebuild (flake-only)'";
        nix-channel   = "echo '❌ nix-channel is deprecated. Use: update'";
        nix-env       = "echo '❌ nix-env is deprecated. Use flakes + HM'";
      };

    };

    # =========================================================
    # 🚀 Zprofile — автозапуск Hyprland при логине
    # =========================================================
    home.file.".zprofile".text = ''
      # Запускать Hyprland только при логине в TTY
      if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ]; then
        exec Hyprland
      fi
    '';
  };

  # ------------------ games ------------------
  services.displayManager.enable = false;

  users.users.games = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "audio" "video" "input" "networkmanager" "bluetooth" "wheel" "render" ];
  };

  home-manager.users.games = {
    home.stateVersion = "24.05";

    home.packages = with pkgs; [
      # X11 / Openbox
      openbox
      xorg.xrandr
      gamescope

      # Игровые приложения
      steam
      steam-run
      ppsspp
      rpcs3

      # Vulkan / OpenGL для игр
      mesa
      vulkan-tools

      # Launcher
      rofi

      firefox
    ];

    home.sessionVariables = {
      WLR_RENDERER = "vulkan";
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
    };

    home.file.".zprofile".text = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ]; then
        exec ${pkgs.gamescope}/bin/gamescope -f -e -- openbox-session
      fi
    '';
  };
  programs.gamemode.enable = true;
  


  services.tor = {
    enable = true;
      torsocks.server = "127.0.0.1:9050";

    client = {
      enable = true;
      # socksListenAddress = "127.0.0.1:9050";
      # dnsListenAddress   = "127.0.0.1:9053";
    };

    settings = {
      UseBridges = true;

      ClientTransportPlugin =
        "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";

      Bridge = [
        "obfs4 140.238.212.58:42069 1D5D7AD4E3BAC71D8B6E34BAC5A0BC3EEF47EB53 cert=KQKyYCBNcYGylWJlFuQIb9qYktsIwRk2bJGuvacDXy7/ny59uAsPdwRMzF3lpH+zwHFfUA iat-mode=0"
        "obfs4 91.5.62.234:8080 3A76222696BA38823C43521FD604189A285D9859 cert=+xdVk09QmI7rY//B/hkW4PfdKyo4B7gEquHExKYfQCfWfFjkW0+bbj6NqBdoc0elJPvpKQ iat-mode=0"
        "obfs4 51.38.220.224:30996 22494A012CFA8C88B1D907E2CCB8409AC35B537B cert=dOPijSCG6FD89fYv5N2F9QoeK1od3tpG6VBE/kMY0Bt1aW/7aXPIzsENDoLWZe43gI8efw iat-mode=0"
        "obfs4 57.128.59.134:24102 A4AE24E2BF9CCD542A9F2794D534D13A39F2F161 cert=dX8/pc880Ne2bMEfmw75yFmsbnoZ+rWl4NDIjrei/ADZ/nHAiYTUw2HodxTIW8cWaKEkKQ iat-mode=0"
      ];

      AutomapHostsOnResolve = true;
      VirtualAddrNetworkIPv4 = "10.192.0.0/10";

      ControlPort = 9051;
      CookieAuthentication = true;
    };
  };

}