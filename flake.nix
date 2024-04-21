{
  description = "VSCode To NixOS Via SSH";

  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils,  nixos-generators }:
    let
      system = "x86_64-linux";
      stateVersion = "23.11";
    in
    rec {
      packages.${system} = {
      generate-ova = nixos-generators.nixosGenerate {
        inherit system;
        format = "virtualbox";
        modules = [
          ({ ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
          ./configuration.nix
        ];
      };
      nixosConfigurations.devops = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}

