#  features/tor.nix
{ pkgs, lib, ... }:
{
  services.tor = {
      enable = true;
      torsocks.server = "127.0.0.1:9050";

    client = {
      enable = true;
      # socksListenAddress = "127.0.0.1:9050";
      # dnsListenAddress   = "127.0.0.1:9053";
    };

    settings = {
      UseBridges = true;

      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";

      Bridge = [
        "obfs4 195.94.188.201:6191 320F79C08899E6CD339440FD8EF1DA355BC6D38C cert=VZgr2D07/fVl9/bGRtVkBUMHtfVL4QaSYb1Ooa9XRs+DmVEAl/QD3W5QdIF9+jA56OCzFQ iat-mode=0"
        "obfs4 142.118.112.211:37061 9EFB511A7C025E0A1C428CC84EED1075ACB51BDC cert=WYI8145ldWxmvJveOwHdkcFW58ZdYa1OFImR9KvooI7NQxJmeSivyvzSCMLwx19vrejdTw iat-mode=0"
        "obfs4 51.83.248.35:25981 D08B4760D128C1A65506577E063D9D26C2A71815 cert=UJWUh+sIDdOKja/byBM2+qP9AFNl86hkGRFJ/lM1GWKP79eCu3PT4WTXI2gdXYULbQ0EMg iat-mode=0"
        "obfs4 167.235.78.36:40678 C8C01639C3333ED20799C69B149641A6568044BC cert=PWxWCoFmK8B+x8WYbgWmTjfXsmRFjL3P5ptPdvzqks7nzMLroLlXc+wG49hpBlF3UG20bA iat-mode=0"
        "obfs4 217.60.199.246:443 3710D2FE6F18A66B4319335C46C0105F14D39CAA cert=8p94MAE1WKKSwSnmIIkOUzA0eViCP7BX+ova1+rYnz8WIJ5Oos2BxcMg5Qyke++UUXblVw iat-mode=0"
        "obfs4 31.57.241.203:443 A6C34604C1298C236A7E365D99E12EB0071CB4B0 cert=ITI6/e9ltNsVIEe+2UD+C9PjyG1OlgO79ufg5dr38PschhZfa3GOBRCYUdX002XcERuiEQ iat-mode=0"      
        "obfs4 95.217.11.29:22134 9859875C752128125D3179F90BA6351744B09040 cert=W+qSHr6JcFY6UyJiXR3Ec5I5bYHFwDAXNq8HRQU3C56h/aJB8PQqbr8Sq04zKvhEWGbxEw iat-mode=0"        
        "obfs4 162.55.184.210:29299 122E4025415F19FBD991DFA1B45ACA8A19111D2D cert=bwCGiLb7NnlIC5BbPtEQU2lq73eMtlJbuHY5XHjLkb+yMKiX3hI4N06+qCImamam74FgTQ iat-mode=0"
        "obfs4 217.197.91.167:8080 FD756F3B8A6DCA1615D5A37D56351084A34F2E9B cert=Aj0S5iBrz+09wNpfDyR5Ph38FYWOEu0Bpcwka28jfreDCtK6apxkY0tjmfssb/2isK2JPg iat-mode=0"
        "obfs4 5.231.118.30:9402 B66AC09B29BFD12F0769A8540D04DCF3FF4D73BC cert=N48Nc/2+fuHSNSUGxVNcKtoWquwZm5zylU7/KFZwcyCu5Sv/GDGLQwTE+nKea0LwP5DKcQ iat-mode=0"
        "obfs4 162.55.219.253:21358 A43C6D5A85CE5D52486293C507983409ED7C1EC0 cert=t0TUwf8Gu+jz8nxWYAPR/VMqh9k8+efrZFTIg6HNpitEdNH1fT1KlAz51jAZqxQq8/9nEA iat-mode=0"
        "obfs4 91.134.99.56:62962 DD8DF15D1183B2DA2FD61FC0C7B8A7BD4D0BE4C4 cert=B7PCcCqk/Q4U9alsQHeicKUa+QSpILYaCeeRrEfUb9a+g+asGkrG6o6ZEziWI1h2MiwgFw iat-mode=0"
      ];

      # AutomapHostsOnResolve = true;
      # VirtualAddrNetworkIPv4 = "10.192.0.0/10";

      # ControlPort = 9051;
      # CookieAuthentication = true;
    };
  };

  systemd.services.tor.wantedBy = lib.mkForce [];

  environment.systemPackages = with pkgs; [
    tor # обход блокирвок
    torsocks  # прокидывание трафика через tor
    obfs4
    tor-browser
  ];
}