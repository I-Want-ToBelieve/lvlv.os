let
  # The system side: /etc/fish loads the system environment, and fish may be a login shell.
  system = {pkgs, ...}: {
    programs.fish.enable = true;
    environment.shells = [pkgs.fish];
  };
in {
  flake.modules.darwin.fish = system;
  flake.modules.nixos.fish = system;

  flake.modules.homeManager.fish = {
    lib,
    pkgs,
    ...
  }: {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        # Vi key bindings with vim's cursor shapes.
        # https://fishshell.com/docs/current/interactive.html#vi-mode-commands
        fish_vi_key_bindings
        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block
        bind --erase \ct

        ${lib.getExe pkgs.krabby} random
        echo -e "\033[37m\033[0m"
      '';
      # Typed, these expand to the modern tool in place, so the command line shows what runs;
      # pasted commands keep the standard tools and their flags.
      shellAbbrs = {
        cat = "bat --style=plain";
        du = "dust";
        ps = "procs";
      };
      shellAliases.m = "mkdir -p";
      functions = {
        c = {
          description = "Open a path, or the current directory, in VS Code";
          argumentNames = "path_string";
          body = ''
            if test -n "$path_string"
              code $path_string
            else
              code .
            end
          '';
        };
        fcd = {
          description = "Pick a directory below this one with fzf and go there";
          body = "cd (find . -type d | ${lib.getExe pkgs.fzf}); or return";
        };
      };
    };
  };
}
