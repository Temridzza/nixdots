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

    wants = [ "network-online.target" ];
    after = [ "network-online.target" "nss-lookup.target" ];

    serviceConfig = {
      
      ExecStart = "${ciadpi}/bin/ciadpi -o1 -r-5+se -a1 -At,r,s -d1 -n 'google.com' -Qr -f-1 -a1";
      
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