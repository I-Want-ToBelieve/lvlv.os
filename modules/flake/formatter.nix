{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  # `nix fmt` formats the tree and applies the linters' fixes; `nix flake check` fails on
  # unformatted files and on what the linters still find.
  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    programs = {
      alejandra.enable = true;
      # Unused bindings and arguments.
      deadnix.enable = true;
      # Anti-patterns such as `x == true` or repeated attribute keys.
      statix.enable = true;
    };
  };
}
