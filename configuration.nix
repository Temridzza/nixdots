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
  # imports = [
  #   ./hardware-configuration.nix
  # ];

  # =========================================================
  # ⚙️ Базовые настройки системы
  # =========================================================

  services.udisks2.enable = true;


  # =========================================================
  # 🖥️ Графика и Wayland
  # =========================================================
  services.xserver = {
    enable = true;

    displayManager.startx.enable = true;

    desktopManager.lxqt.enable = true;
  };



  # =========================================================
  # 🔵 Bluetooth
  # =========================================================

  systemd.packages = [ pkgs.bluez ]; # Bluetooth daemon


  # =========================================================
  # 🔒 Firejail
  # =========================================================
  programs.firejail = {
    enable = true;
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

    # docker
    # docker
    # docker-compose
    # lazydocker

    gnome-system-monitor
    
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

    
    

    # --- Звук ---
    alsa-utils  # ALSA утилиты
    pipewire    # Аудио сервер
    wireplumber # Менеджер PipeWire

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

    
    openssl
    ags

    opensnitch              #управление трафиком
    opensnitch-ui
    
    cabextract
    winetricks

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
  # 🐚 Zsh
  # =========================================================
  programs.zsh.enable = true;
}