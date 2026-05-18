{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Фиксация версии
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.52.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # оболочка
    ambxst = {
      url = "path:./Ambxst";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # модифицированная тема/скрипт для SDDM
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    ambxst,
    ...
  }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
    };

    mkRebuildScript = mode:
      pkgs.writeShellScript "nixos-${mode}" ''
        set -e

        # последний git commit
        msg=$(git log -1 --pretty=%s 2>/dev/null)

        # fallback если не git repo
        if [ -z "$msg" ]; then
          msg="manual build"
        fi

        # ограничение длины
        msg=$(echo "$msg" | cut -c1-60)

        # безопасный slug
        msg=$(echo "$msg" \
          | tr '[:upper:]' '[:lower:]' \
          | sed 's/[^a-z0-9]/-/g' \
          | sed 's/-\+/-/g' \
          | sed 's/^-//; s/-$//')

        date_part=$(date +"%H-%M")

        label="$msg-_$date_part"

        echo "🧠 NixOS label: $label"
        echo "⚙ Rebuild mode: ${mode}"

        sudo GIT_LABEL="$label" \
          nixos-rebuild ${mode} --flake . --impure
      '';

    switchScript = mkRebuildScript "switch";
    bootScript = mkRebuildScript "boot";

  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./hosts/nixos.nix
        ./configuration.nix

        home-manager.nixosModules.home-manager

        inputs.ambxst.nixosModules.default
        inputs.silentSDDM.nixosModules.default
      ];

      specialArgs = {
        inherit inputs self;
      };
    };

    apps.${system} = {
      switch = {
        type = "app";
        program = toString switchScript;
      };
      boot = {
        type = "app";
        program = toString bootScript;
      };
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        cmake
        ninja
        gcc
        gdb
        pkg-config

        qt6.qtbase
        qt6.qttools
        qt6.qtwayland

        curl
        gtest
      ];

      shellHook = ''
        export QT_QPA_PLATFORM=wayland
      '';
    };
  };
}