{
  users.users = {
    game = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"          # sudo
        "networkmanager"# сеть
        "audio"          # звук
        "video"          # видео
        "input"          # устройства ввода
        "tty"
        "uinput"
        "bluetooth"
        # "docker"
        "tor"
      ];
    };

    temridzza = {
      isNormalUser = true;
      shell = pkgs.zsh; # Основная оболочка

      extraGroups = [
        "wheel"          # sudo
        "networkmanager"# сеть
        "audio"          # звук
        "video"          # видео
        "input"          # устройства ввода
        "tty"
        "uinput"
        "bluetooth"
        # "docker"
        "tor"
        "libvirtd"     
      ];

      packages = with pkgs; [
        tree # Отображение структуры каталогов
      ];
    };

    jellyfin = {
      extraGroups = [ "users" ];
    };
  };

  systemd.tmpfiles.rules = [
    # доступ к домашней папке (чтобы можно было "зайти")
    "d /home/temridzza 0711 temridzza users - -"

    # папка с медиа
    "d /home/temridzza/Movies 0750 temridzza media - -"
  ];

  security.sudo.extraRules = [
    {
      users = [ "temridzza" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl stop tor";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl restart tor";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units") {
            if (subject.user == "temridzza") {
                return polkit.Result.YES;
            }
        }
    });
  '';
}