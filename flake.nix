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

    ambxst = {
      url = "path:./Ambxst";
      inputs.nixpkgs.follows = "nixpkgs";
    };   
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ambxst, ... }:
  let
    system = "x86_64-linux";

    # git commit прямо в сборку
    pkgs = import nixpkgs { inherit system; };
    switchScript = pkgs.writeShellScript "nixos-switch" ''
      set -e

      # получаем последний commit message
      msg=$(git log -1 --pretty=%s 2>/dev/null)

      # fallback если не git repo
      if [ -z "$msg" ]; then
        msg="manual build"
      fi

      # ограничение длины
      msg=$(echo "$msg" | cut -c1-60)

      echo "🧠 NixOS label: $msg"

      sudo GIT_LABEL="$msg" nixos-rebuild switch --flake .
    '';
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/nixos.nix
        home-manager.nixosModules.home-manager
        inputs.ambxst.nixosModules.default
      ];
      specialArgs = {
        inherit inputs self;
      };        
    };

    apps.${system}.switch = {
      type = "app";
      program = toString switchScript;
    };
  };
}
