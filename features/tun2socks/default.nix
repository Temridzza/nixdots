{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tun2socks

    (pkgs.writeShellScriptBin "proxy-on" ''
      set -e

      # создать tun если нет
      ${pkgs.iproute2}/bin/ip tuntap add dev tun0 mode tun 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip addr add 198.18.0.1/15 dev tun0 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip link set tun0 up

      # запустить туннель
      systemctl start socks-tunnel

      # увести default route в tun
      ${pkgs.iproute2}/bin/ip route replace default dev tun0

      echo "[proxy] ON"
    '')

    (pkgs.writeShellScriptBin "proxy-off" ''
      set -e

      systemctl stop socks-tunnel

      ${pkgs.iproute2}/bin/ip route del default dev tun0 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip link set tun0 down 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip tuntap del dev tun0 mode tun 2>/dev/null || true

      echo "[proxy] OFF"
    '')
  ];

  systemd.services.socks-tunnel = {
    description = "SOCKS system tunnel (tun2socks)";

    after = [ "network.target" ];
    wantedBy = [ ];

    serviceConfig = {
      Type = "simple";

      ExecStart = ''
        ${pkgs.tun2socks}/bin/tun2socks \
          -device tun0 \
          -proxy socks5://192.168.0.120:12334
      '';

      ExecStop = "${pkgs.iproute2}/bin/ip link set tun0 down";

      Restart = "no";
      AmbientCapabilities = "CAP_NET_ADMIN";
    };
  };
}