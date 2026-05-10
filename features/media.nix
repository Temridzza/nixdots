# features/media.nix
{ pkgs, lib, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.jellyfin.wantedBy = lib.mkForce [];

  environment.systemPackages = with pkgs; [
    mpv # медиаплеер
    mpvScripts.mpris  # MPRIS скрипт для mpv
    obs-studio # Запись экрана
    ffmpeg # Работа с видео/аудио
    cava #
    pavucontrol # GUI микшер
    pamixer # CLI микшер
  ];
}