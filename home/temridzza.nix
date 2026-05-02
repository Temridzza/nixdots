# home/temridzza.nix
{ pkgs, inputs, ... }:
{
  home-manager.users.temridzza = { lib, pkgs, ... }: {
       
    home.stateVersion = "24.05";

    # extraSpecialArgs = {
    #   inherit inputs;
    # };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    # 👉 Симлинк ~/.config/hypr → /etc/nixos/home/temridzza/hypr
    xdg.configFile."hypr".source = ././home/temridzza/hypr;
    xdg.configFile = {
      "cava".source    = ././home/temridzza/config/cava;
      "waybar".source  = ./././home/temridzza/config/waybar;
      "rofi".source    = ././home/temridzza/config/rofi;
      "kitty".source   = ././home/temridzza/config/kitty;
      "wallust".source = ././home/temridzza/config/wallust;
      "wlogout".source = ././home/temridzza/config/wlogout;
      "btop".source = ././home/temridzza/config/btop;
      "fastfetch".source = ././home/temridzza/config/fastfetch;
      # "swaync".source = ././home/temridzza/config/swaync;
      "swappy".source = ././home/temridzza/config/swappy;
    };

    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "half-life";
        plugins = [ "git" "sudo" "extract" ];
      };

      # === ПЛАГИНЫ ===
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

      # === АЛИАСЫ (lsd, clear, reload) ===
      shellAliases = {
        ls   = "lsd";
        l    = "ls -l";
        la   = "ls -a";
        lla  = "ls -la";
        lt   = "ls --tree";
        c    = "clear";
        reload = "source ~/.zshrc";

        # ✅ Flake-only workflow
        rebuild = "/etc/nixos/home/temridzza/hypr/myScripts/rebuild-commit.sh";
        rebuild- = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
        update  = "cd /etc/nixos && nix flake update && rebuild";

        # ❌ Блокировка legacy-путей
        nixos-rebuild = "echo '❌ Use: rebuild (flake-only)'";
        nix-channel   = "echo '❌ nix-channel is deprecated. Use: update'";
        nix-env       = "echo '❌ nix-env is deprecated. Use flakes + HM'";
      };

    };

    # =========================================================
    # 🚀 Zprofile — автозапуск Hyprland при логине
    # =========================================================
    home.file.".zprofile".text = ''
      # Запускать Hyprland только при логине в TTY
      if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ]; then
        exec Hyprland
      fi
    '';    

    # ------------------
    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    home.file.".local/bin/easyeffects" = {
      executable = true;
      text = ''
        #!/bin/sh
        exit 0
      '';
    };

    programs.mpv = {
      enable = true;
      scripts = [
        pkgs.mpvScripts.mpris
      ];
    };
  };

  home-manager.users.game = { pkgs, ... }: {
    home.stateVersion = "24.05";

    # =========================================================
    # 🚀 Zprofile — автозапуск lxqt при логине
    # =========================================================
    home.file.".zprofile".text = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec startx
      fi
    '';

    home.file.".xinitrc".text = ''
      exec startlxqt
    '';
  };
}