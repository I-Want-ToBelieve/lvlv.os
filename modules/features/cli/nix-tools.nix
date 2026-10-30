{
  flake.modules.homeManager.nix-tools = {
    lib,
    pkgs,
    ...
  }: {
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

      # Scripts rather than shell functions, so that every shell has them.
      (pkgs.writeShellApplication {
        name = "run";
        text = ''
          # run <package> [arguments]: run a nixpkgs package without installing it.
          package=$1
          shift
          exec nix run "nixpkgs#$package" -- "$@"
        '';
      })
      (pkgs.writeShellApplication {
        name = "nix-search";
        runtimeInputs = [pkgs.fzf];
        text = ''
          # nix-search [flake]: pick a package of nixpkgs (or the flake) with fzf.
          flake=''${1:-nixpkgs}
          nix search "$flake" ".*" --json |
            ${lib.getExe pkgs.jq} -r 'keys[] | sub("^legacyPackages\\.[^.]+\\."; "")' |
            fzf --preview="nix search $flake '^{}\$'"
        '';
      })
    ];

    # `nh darwin switch .` / `nh os switch .` build with nom and show the nvd diff before
    # switching. Garbage collection stays with nix.gc.
    programs.nh.enable = true;
  };
}
