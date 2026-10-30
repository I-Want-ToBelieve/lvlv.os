# An Intel Mac. x86_64-darwin hosts are built from the 26.05 inputs (see flake.nix and
# modules/flake/systems.nix), the last release of nixpkgs that supports them.
let
  user = "i.want.to.believe";
in {
  lvlv.hosts.k99lite-darwin-x64 = {
    class = "darwin";
    system = "x86_64-darwin";
    # The nix-darwin state of the first install, the newest that nix-darwin 26.05 knows;
    # never change it.
    stateVersion = 7;
    profiles = ["desktop"];
    features = ["i-want-to-believe"];
    modules = [
      {
        system.primaryUser = user;
        # Staying on 26.05 is the answer to its deprecation warning.
        nixpkgs.config.allowDeprecatedx86_64Darwin = true;
        # The uninstaller evaluates a second system without this nixpkgs.config, which brings
        # the warning back; `nix run nix-darwin/nix-darwin-26.05#darwin-uninstaller` still works.
        system.tools.darwin-uninstaller.enable = false;
        # Stylix is the version the features are written for, ahead of nix-darwin 26.05 on
        # purpose (modules/flake/systems.nix), so its release check would only warn about that.
        stylix.enableReleaseChecks = false;
      }
    ];
    home.${user} = {
      stateVersion = "26.05";
      profiles = ["cli" "desktop"];
      modules = [
        {
          # Home Manager and nixvim are the versions the features are written for, ahead of
          # 26.05 nixpkgs on purpose (modules/flake/systems.nix); this host evaluates and
          # builds with them, so their release checks would only warn about that choice.
          home.enableNixpkgsReleaseCheck = false;
          programs.nixvim.version.enableNixpkgsReleaseCheck = false;
          # nix-index-database publishes no database for x86_64-darwin.
          programs.nix-index.enable = false;
          programs.nix-index-database.comma.enable = false;
          # No host runs nushell, yet Home Manager's fzf integration for it asserts an fzf
          # newer than 26.05 has.
          home.shell.enableNushellIntegration = false;
        }
      ];
    };
  };
}
