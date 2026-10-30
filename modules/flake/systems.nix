{
  lib,
  inputs,
  ...
}: {
  imports = [inputs.flake-parts.flakeModules.modules];

  options.lvlv.inputsFor = lib.mkOption {
    type = lib.types.functionTo (lib.types.attrsOf lib.types.raw);
    readOnly = true;
    description = "The nixpkgs and nix-darwin inputs that build for a system.";
  };

  config = {
    # Per-system outputs (checks, dev shell, formatter, apps) are built for these,
    # and a host's `system` must be one of them.
    systems = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    # Unstable nixpkgs refuses to evaluate for x86_64-darwin, so Intel Macs take nixpkgs and
    # nix-darwin from the 26.05 inputs in flake.nix, for their hosts and per-system outputs
    # alike. Home Manager and the other module inputs stay on the versions the features are
    # written against; their options still work with 26.05 packages.
    lvlv.inputsFor = system:
      if system == "x86_64-darwin"
      then {
        nixpkgs = inputs.nixpkgs-x64;
        nix-darwin = inputs.nix-darwin-x64;
      }
      else {inherit (inputs) nixpkgs nix-darwin;};

    perSystem = {system, ...}: {
      _module.args.pkgs =
        if system == "x86_64-darwin"
        then
          import inputs.nixpkgs-x64 {
            inherit system;
            # Staying on 26.05 is the answer to its deprecation warning.
            config.allowDeprecatedx86_64Darwin = true;
          }
        else inputs.nixpkgs.legacyPackages.${system};
    };
  };
}
