# Flake Integration

## Adding plasma-manager to flake.nix

### Step 1: Add the input

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
};
```

Both `follows` lines are critical to avoid duplicate nixpkgs evaluations.

### Step 2: Wire as a home-manager shared module

```nix
home-manager.nixosModules.home-manager
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.username = import ./home-manager/home.nix;
  home-manager.sharedModules = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];
}
```

### Step 3: Enable in home.nix

```nix
programs.plasma = {
  enable = true;
  # configuration goes here
};
```

## This Repository

Already integrated in `flake.nix` (line 22-27) with shared module (line 69). Just add `programs.plasma` block to home config.

## Applying Changes

```bash
sudo nixos-rebuild switch --flake ~/nixos#rhea
```

Some changes (panels, widgets, desktop scripts) require a Plasma restart or logout/login to take effect. Theme changes via `plasma-apply-*` tools apply on first login after rebuild.

## rc2nix: Import Existing Config

Convert current KDE settings to Nix expressions:

```bash
nix run github:nix-community/plasma-manager -- rc2nix
# Or with nested format (recommended):
nix run github:nix-community/plasma-manager -- rc2nix -n
```

This outputs `configFile` entries. Review and manually convert to high-level options where possible.
