{
  flake.modules.homeManager.nix-tools = {pkgs, ...}: {
    home.packages = [
      pkgs.alejandra
      pkgs.cachix
      pkgs.deadnix
      pkgs.nil
      pkgs.nix-init
      pkgs.statix
    ];
  };
}
