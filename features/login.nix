# features/login.nix
{
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        user = "temridzza";
        command = "Hyprland";
      };
    };
  };
}