# features/dev.nix
{ pkgs, ... }:
 let
    qt6Full = pkgs.qt6.qtbase.overrideDerivation (old: {
    # tools = [ "all" ] включает все инструменты Qt6: syncqt, moc, uic и т.д.
    tools = [ "all" ]; 
  });
in
{
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    cmake
    ninja
    pkg-config

    qt6.qtbase
    qt5.qtbase
    qt6.qtsvg
    qt6.qtwayland
    qt6.qtimageformats
    kdePackages.qtmultimedia
    kdePackages.qtshadertools
    kdePackages.syntax-highlighting
    qt6.qtmultimedia

    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtmultimedia
    libsForQt5.qt5.qtconnectivity

    libsForQt5.qtbase
    libsForQt5.qtmultimedia
    libsForQt5.qtconnectivity

    qt5.qtmultimedia
    qt5.qtconnectivity
    qt6.qtdeclarative
    
    gtest
    qt6.qttools
    qtcreator
    # insomnia # альтернатива postman

    python315
    openssl

    # wine stuff
    cabextract
    winetricks

    # Qt
    # qt6Full
  ];

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


}