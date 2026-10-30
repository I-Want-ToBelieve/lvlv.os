{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  # `nix fmt` formats the tree; `nix flake check` fails on unformatted files.
  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    programs.alejandra.enable = true;
  };
}
