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
  };

  outputs =
    { nixpkgs, noctalia, ... }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          noctalia.nixosModules.default
        ];
      };
    };
}
