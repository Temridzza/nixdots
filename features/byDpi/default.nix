{ config, lib, pkgs, ... }:

let
  ciadpi = pkgs.stdenv.mkDerivation {
    name = "ciadpi";
    src = ./ciadpi;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/ciadpi
      chmod +x $out/bin/ciadpi
    '';
  };
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
      ExecStart = "${ciadpi}/bin/ciadpi --split 2 --disorder 3 --tlsrec 1+s --max-conn 16384";

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