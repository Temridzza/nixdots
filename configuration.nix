{ config, lib, pkgs, inputs, ... }:
  let
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
  # 🖥️ Графика и Wayland
  # =========================================================
  services.xserver = {
    enable = true;

    displayManager.startx.enable = true;

    desktopManager.lxqt.enable = true;
  };

  # =========================================================
  # 🔒 Firejail
  # =========================================================
  programs.firejail = {
    enable = true;
  };

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
    polkit_gnome

    mesa
    
    firejail
    iptables

    # --- Звук ---
    alsa-utils  # ALSA утилиты
    pipewire    # Аудио сервер
    wireplumber # Менеджер PipeWire

    
    
    liberation_ttf_v1

    
    openssl
    ags
    
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