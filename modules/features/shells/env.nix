# The environment every shell starts with.
{
  flake.modules.homeManager.shell-env = {config, ...}: {
    # LANG for every shell; the individual LC_* categories follow it.
    home.language.base = "en_US.UTF-8";

    # Directories of tools installed outside Nix (scripts, cargo, npm, yarn, go).
    home.sessionPath = map (dir: "${config.home.homeDirectory}/${dir}") [
      ".local/bin"
      ".cargo/bin"
      ".npm/bin"
      ".yarn/bin"
      "go/bin"
    ];
  };
}
