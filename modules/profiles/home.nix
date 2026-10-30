# What one user gets in their Home Manager configuration. A host feature that also has a
# homeManager part reaches every user of the host without being listed here.
{
  lvlv.profiles.homeManager = {
    cli = [
      "shell-env"
      "git"
      "direnv"
      "ssh"
      "starship"
      "nix-index"
      "nix-tools"
      "cli-tools"
      "nushell"
    ];
    desktop = [
      "kitty"
      "gui-apps"
    ];
  };
}
