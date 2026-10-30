{
  flake.modules.homeManager.nix-tools = {pkgs, ...}: {
    home.packages = [
      pkgs.alejandra
      pkgs.cachix
      pkgs.deadnix
      pkgs.nil
      pkgs.nix-init
      # `nom build`: readable build progress.
      pkgs.nix-output-monitor
      # `nvd diff <old> <new>`: package changes between two generations.
      pkgs.nvd
      pkgs.statix
    ];

    # `nh darwin switch .` / `nh os switch .` build with nom and show the nvd diff before
    # switching. Garbage collection stays with nix.gc.
    programs.nh.enable = true;
  };
}
