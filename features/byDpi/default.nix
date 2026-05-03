{ config, lib, pkgs, ... }:

let
  ciadpi = pkgs.writeShellScriptBin "ciadpi" (builtins.readFile ./ciadpi.sh);
in
{
  environment.systemPackages = [
    ciadpi
    pkgs.byedpi
  ];

  systemd.services.byedpi = {
    description = "ByeDPI";
    documentation = [ "https://github.com/hufrea/byedpi" ];

    wantedBy = [ "multi-user.target" ];

    wants = [ "network-online.target" ];
    after = [ "network-online.target" "nss-lookup.target" ];

    serviceConfig = {
      ExecStart = "${ciadpi}/bin/ciadpi";

      Environment = [
        "BYEDPI_OPTIONS=--split 4 --disorder 2 --tlsrec 4+s"
      ];

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "full";
      LimitNOFILE = 65535;

      StandardOutput = "null";
      StandardError = "journal";

      TimeoutStopSec = "5s";
    };
  };
}