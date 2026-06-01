{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [

    # docker
    docker
    docker-compose
    lazydocker

    # тестирования API
    insomnia
  ];
  # docker
  virtualisation.docker.enable = true;
  security.polkit.enable = true;
}
