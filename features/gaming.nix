# features/gaming.nix
{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    steam
    gamescope # steam оболочка
    steam-run
  ];

  programs.gamemode = {
    enable = true;

    settings = {
      scripts = {
        start = ''
          ${pkgs.systemd}/bin/systemd-run --user --collect \
            ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
        '';

        end = ''
          ${pkgs.systemd}/bin/systemd-run --user --collect \
            ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
        '';
      };
    };
  };
  
}