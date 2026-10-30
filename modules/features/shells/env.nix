# The environment every shell starts with.
{
  flake.modules.homeManager.shell-env = {
    config,
    lib,
    pkgs,
    ...
  }: {
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

    # Aliases for fish and zsh alike. Aliases that need a particular shell's syntax stay in
    # that shell's feature.
    home.shellAliases = {
      g = "git";
      m = "mkdir -p";
      # Python's built-in file server for the current directory.
      serve = "${lib.getExe pkgs.python3} -m http.server";
      # ouch picks the format from the file, so one command covers every archive.
      extract = "${lib.getExe pkgs.ouch} decompress";
      ytmp3 = ''${lib.getExe pkgs.yt-dlp} -x --audio-format mp3 --audio-quality 0 --embed-metadata --embed-thumbnail --parse-metadata "title:%(artist)s - %(title)s" -o "%(title)s.%(ext)s"'';
      cleanup = "sudo nix-collect-garbage --delete-older-than 7d";
      bloat = "nix path-info -Sh /run/current-system";
    };
  };
}
