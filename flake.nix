{
  description = "aditya's NixOS configuration - niri + noctalia";

  inputs = {
    # Pinned to the channel this system is already on, so converting to a
    # flake does not move you to unstable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Noctalia v5. The `cachix` branch is the one upstream builds into
    # https://noctalia.cachix.org -- deliberately NO `inputs.nixpkgs.follows`
    # here, because overriding its nixpkgs changes every derivation hash and
    # misses the cache, forcing a local C++ compile on every update.
    noctalia.url = "github:noctalia-dev/noctalia-shell/cachix";

    # Only claude-code is taken from here, via the overlay below. 26.05 lags
    # several hundred patch versions behind upstream on this package.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, noctalia, ... }:
    let
      # NOTE: must `import` nixpkgs-unstable rather than use its
      # `legacyPackages`. legacyPackages is pre-instantiated with the default
      # config, where allowUnfree = false -- and claude-code is unfree. The
      # `nixpkgs.config.allowUnfree` in configuration.nix only applies to the
      # outer nixpkgs instance that nixosSystem builds, never to this one.
      overlay = final: prev: {
        claude-code =
          (import nixpkgs-unstable {
            inherit (prev) system;
            config.allowUnfree = true;
          }).claude-code;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          noctalia.nixosModules.default
          { nixpkgs.overlays = [ overlay ]; }
        ];
      };
    };
}
