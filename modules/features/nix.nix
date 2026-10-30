# Nix and nixpkgs settings for NixOS and nix-darwin hosts.
let
  shared = {pkgs, ...}: {
    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        # Mirrors in China first, cache.nixos.org as the fallback.
        substituters = [
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://cache.nixos.org/"
        ];
        # Prebuilt packages of nix-community projects (home-manager, nixvim, nix-index, ...).
        extra-substituters = ["https://nix-community.cachix.org"];
        extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
        # The default 64 MiB fills up on large downloads and warns "download buffer is full".
        download-buffer-size = 256 * 1024 * 1024;
        builders-use-substitutes = true;
        # Keep what direnv shells were built from across garbage collections.
        keep-outputs = true;
        keep-derivations = true;
        # Collect garbage during a build once less than 100 MiB is free, until 1 GiB is.
        min-free = 100 * 1024 * 1024;
        max-free = 1024 * 1024 * 1024;
        warn-dirty = false;
      };
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };
      optimise.automatic = true;
    };
    nixpkgs.config.allowUnfree = true;
    # Flakes need git.
    environment.systemPackages = [pkgs.git];
  };
in {
  flake.modules.nixos.nix = {
    imports = [shared];
    nix = {
      settings = {
        trusted-users = ["root" "@wheel"];
        allowed-users = ["@wheel"];
        # Look up registry names such as `nixpkgs` locally instead of fetching the global registry.
        flake-registry = "/etc/nix/registry.json";
      };
      gc.dates = "weekly";
    };
    # Install nothing by default; features and hosts add what they use.
    environment.defaultPackages = [];
    documentation.doc.enable = false;
  };

  flake.modules.darwin.nix = {
    imports = [shared];
    nix.settings.trusted-users = ["root" "@admin"];
  };
}
