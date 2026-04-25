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

  networking.firewall.allowedTCPPorts = [
    80
    443
    2222
    27015
    27036
    27037
    2221

    # Sunshine / Moonlight
    47984
    47989
    47990
    48010

    # android studio
    42125
    41849

    1080 # ByeDPI SOCKS proxy

    30 #sing-box
    9050

    8118 #privoxy
  ];

  networking.firewall.allowedUDPPorts = [
    10400
    10401
    27015
    27036
    2221
    

    # Sunshine / Moonlight
    47998
    47999
    48000
    48010

    # android studio
    42125
    41849

    30 #sing-box
    9050

    8118 #privoxy
  ];

  # для bydpi по всей home сети 
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
  networking.nat = {
    enable = true;
    externalInterface = "wlp0s20f3";
  };

  # =========================================================
  # 🔒 waydroid
  # =========================================================

  virtualisation.waydroid.enable = true;

  networking.nftables.enable = false;

  networking.firewall = {
    enable = true;
  };

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
  users.users = {
    game = {
      isNormalUser = true;
      shell = pkgs.zsh;
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
    };

    temridzza = {
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
        "libvirtd"
      ];

      packages = with pkgs; [
        tree # Отображение структуры каталогов
      ];
    };
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

    #docker
    docker
    docker-compose
    lazydocker

    obfs4
    gnome-system-monitor
    xar
    cava
    udisks
    unrar
    zip
    python315
    macchanger
    

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
    iptables


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
    ncdu                    # просмотр диска
    rofi
    thunderbird
    geary
    obs-studio
    libreoffice
    networkmanagerapplet
    gamescope
    tor-browser
    sunshine
    android-studio
    filezilla
    waydroid

    (writeShellScriptBin "firefox-fj" ''
      mkdir -p $HOME/.firefox-fj
      exec firejail \
        --private=$HOME/.firefox-fj \
        --profile=${firefoxFirejailProfile} \
        ${pkgs.firefox}/bin/firefox "$@"
    '')

    (writeShellScriptBin "firefox-youtube" ''
      mkdir -p $HOME/.firefox-youtube
      exec firejail \
        --private=$HOME/.firefox-youtube \
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

    # для bydpi
    gnumake
    gcc

    # для LXQt
    lxqt.lxqt-session
    xorg.xinit
    xorg.xorgserver
    openbox

    # виртуализация с аппартаной поддержкой
    qemu
    virt-manager
    virt-viewer
    spice
    spice-gtk
    cdrkit

    # bydpi раздача
    # sing-box #tun2socks

    # для postman
    postman
    insomnia # альтернатива postman
  ];

  services.privoxy = {
    enable = true;

    settings = {
      listen-address = "0.0.0.0:8118";

      forward-socks5 = "/ 127.0.0.1:1080 .";
    };
  };

  # для virtualBox
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

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
  
  home-manager.users.temridzza = { lib, pkgs, ... }: {
       
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
        rebuild = "/etc/nixos/home/temridzza/hypr/myScripts/rebuild-commit.sh";
        update  = "cd /etc/nixos && nix flake update && rebuild";
        
        rebuild_notScript = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
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

    # ------------------
    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    home.file.".local/bin/easyeffects" = {
      executable = true;
      text = ''
        #!/bin/sh
        exit 0
      '';
    };
  };

  home-manager.users.game = { pkgs, ... }: {
    home.stateVersion = "24.05";

    # =========================================================
    # 🚀 Zprofile — автозапуск lxqt при логине
    # =========================================================
    home.file.".zprofile".text = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec startx
      fi
    '';

    home.file.".xinitrc".text = ''
      exec startlxqt
    '';
  };

  # ------------------ games ------------------
  # services.displayManager.enable = false;
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

      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";

      Bridge = [
        "obfs4 195.94.188.201:6191 320F79C08899E6CD339440FD8EF1DA355BC6D38C cert=VZgr2D07/fVl9/bGRtVkBUMHtfVL4QaSYb1Ooa9XRs+DmVEAl/QD3W5QdIF9+jA56OCzFQ iat-mode=0"
        "obfs4 142.118.112.211:37061 9EFB511A7C025E0A1C428CC84EED1075ACB51BDC cert=WYI8145ldWxmvJveOwHdkcFW58ZdYa1OFImR9KvooI7NQxJmeSivyvzSCMLwx19vrejdTw iat-mode=0"
        "obfs4 51.83.248.35:25981 D08B4760D128C1A65506577E063D9D26C2A71815 cert=UJWUh+sIDdOKja/byBM2+qP9AFNl86hkGRFJ/lM1GWKP79eCu3PT4WTXI2gdXYULbQ0EMg iat-mode=0"
        "obfs4 167.235.78.36:40678 C8C01639C3333ED20799C69B149641A6568044BC cert=PWxWCoFmK8B+x8WYbgWmTjfXsmRFjL3P5ptPdvzqks7nzMLroLlXc+wG49hpBlF3UG20bA iat-mode=0"
        "obfs4 217.60.199.246:443 3710D2FE6F18A66B4319335C46C0105F14D39CAA cert=8p94MAE1WKKSwSnmIIkOUzA0eViCP7BX+ova1+rYnz8WIJ5Oos2BxcMg5Qyke++UUXblVw iat-mode=0"
        "obfs4 31.57.241.203:443 A6C34604C1298C236A7E365D99E12EB0071CB4B0 cert=ITI6/e9ltNsVIEe+2UD+C9PjyG1OlgO79ufg5dr38PschhZfa3GOBRCYUdX002XcERuiEQ iat-mode=0"      
        "obfs4 95.217.11.29:22134 9859875C752128125D3179F90BA6351744B09040 cert=W+qSHr6JcFY6UyJiXR3Ec5I5bYHFwDAXNq8HRQU3C56h/aJB8PQqbr8Sq04zKvhEWGbxEw iat-mode=0"        
        "obfs4 162.55.184.210:29299 122E4025415F19FBD991DFA1B45ACA8A19111D2D cert=bwCGiLb7NnlIC5BbPtEQU2lq73eMtlJbuHY5XHjLkb+yMKiX3hI4N06+qCImamam74FgTQ iat-mode=0"
      ];

      # AutomapHostsOnResolve = true;
      # VirtualAddrNetworkIPv4 = "10.192.0.0/10";

      # ControlPort = 9051;
      # CookieAuthentication = true;
    };
  };

  services.minidlna = {
    enable = true;
    openFirewall = true;

    settings = {
      media_dir = [
        "V,/home/temridzza/media/videos"
        "A,/home/temridzza/Music"
        "P,/home/temridzza/media/pictures"
      ];
      friendly_name = "NixOS DLNA";
      inotify = "yes";
    };
  };
  
}