{ pkgs, ... }:

let
  ambxstWrapped = pkgs.writeShellScriptBin "/etc/nixos/Ambxst/cli.sh" ''
    export PATH="/run/current-system/sw/bin:$PATH"

    export QML2_IMPORT_PATH="/run/current-system/sw/lib/qt-6/qml:$QML2_IMPORT_PATH"
    export QML_IMPORT_PATH="$QML2_IMPORT_PATH"

    export QT_PLUGIN_PATH="/run/current-system/sw/lib/qt-6/plugins:$QT_PLUGIN_PATH"
    export LD_LIBRARY_PATH="/run/current-system/sw/lib:$LD_LIBRARY_PATH"

    exec /etc/nixos/Ambxst/cli.sh "$@"
  '';
in
{
  environment.systemPackages = [ ambxstWrapped ];
}