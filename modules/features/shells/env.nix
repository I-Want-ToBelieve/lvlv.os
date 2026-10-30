# Directories of tools installed outside Nix (scripts, cargo, npm, yarn, go), for every shell.
{
  flake.modules.homeManager.shell-env = {config, ...}: {
    home.sessionPath = map (dir: "${config.home.homeDirectory}/${dir}") [
      ".local/bin"
      ".cargo/bin"
      ".npm/bin"
      ".yarn/bin"
      "go/bin"
    ];
  };
}
