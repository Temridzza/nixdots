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
    gdb
    clang
    clazy
    lldb
    nlohmann_json

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
    cmark-gfm
    
    gtest
    qt6.qttools
    qtcreator

    python315
    openssl

    # wine stuff
    cabextract
    winetricks

    sqlitebrowser # просмотр .db файлов
    kdePackages.qt5compat
    qt6.qt5compat
  ];


}