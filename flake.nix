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
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          inputs.ambxst.nixosModules.default
        ];
        specialArgs = {
          inherit inputs;
        };        
      };
    };
}
