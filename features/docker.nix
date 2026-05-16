{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [

    # docker
    docker
    docker-compose
    lazydocker
  ];
  # docker
  virtualisation.docker.enable = true;
  security.polkit.enable = true;
}
