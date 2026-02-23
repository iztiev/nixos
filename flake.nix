{
  description = "NixOS RHEA";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

#    izosevka.url = "github:iztiev/Izosevka";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-flatpak, firefox-addons, plasma-manager, lanzaboote, ... }: {
    nixosConfigurations.rhea = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        ./nixos/hardware-configuration.nix
        ./nixos/configuration.nix
        ./modules/nixos

#        inputs.izosevka.nixosModules.default

        lanzaboote.nixosModules.lanzaboote
        nix-flatpak.nixosModules.nix-flatpak
        inputs.sops-nix.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.iztiev = import ./home-manager/home.nix;
          home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
