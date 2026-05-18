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

      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };

    # 👉 Симлинк ~/.config/hypr → /etc/nixos/home/temridzza/hypr
    xdg.configFile."hypr".source = ./temridzza/hypr;
    xdg.configFile = {
      "cava".source    = ./temridzza/config/cava;
      "waybar".source  = ./temridzza/config/waybar;
      "rofi".source    = ./temridzza/config/rofi;
      "kitty".source   = ./temridzza/config/kitty;
      "wallust".source = ./temridzza/config/wallust;
      "wlogout".source = ./temridzza/config/wlogout;
      "btop".source = ./temridzza/config/btop;
      "fastfetch".source = ./temridzza/config/fastfetch;
      # "swaync".source = ./temridzza/config/swaync;
      "swappy".source = ./temridzza/config/swappy;
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
        rebuild = "/etc/nixos/features/scripts/rebuild-commit.sh";
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
}