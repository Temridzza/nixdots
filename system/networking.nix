# system/networking.nix
{ pkgs, ... }:
{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;

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
    53
    443
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
    53
    443
  ];

  networking.nat = {
    enable = true;
    externalInterface = "wlp0s20f3";
  };

  environment.systemPackages = with pkgs; [
    iptables

    dig
  ];
  
  programs.firejail = {
    enable = true;
  };

  # services.dnsproxy = {
  #   enable = true;
  #   settings = {
  #     upstream = [ "https://xbox-dns.ru/dns-query" ];

  #     listen-addrs = [ "127.0.0.1" ];
  #     listen-ports = [ 53 ];
  #   };

  #   flags = [ "--verbose" ];
  # };

  # networking.networkmanager.dns = "none";
  # networking.nameservers = [ "127.0.0.1" ];

  networking.nameservers = [ "192.168.0.1" ];

  #networking.networkmanager.dns = "none";
  #networking.nameservers = [ "127.0.0.1" ];
}