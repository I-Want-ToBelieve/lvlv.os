{inputs, ...}: {
  flake.modules.homeManager.nix-index = {
    # A prebuilt nix-index database instead of indexing locally.
    imports = [inputs.nix-index-database.homeModules.nix-index];
    # `, <command>` runs a command from nixpkgs without installing it.
    programs.nix-index-database.comma.enable = true;
  };
}
