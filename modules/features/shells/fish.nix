{
  flake.modules.darwin.fish = {pkgs, ...}: {
    programs.fish.enable = true;
    # nix-darwin puts a shell in /etc/shells only when it is listed here.
    environment.shells = [pkgs.fish];
  };

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
      shellAliases = {
        ls = "eza --sort type";
        l = "ls -la";
        lt = "ls --tree";
        ra = "yazi";
        g = "git";
      };
      functions.c = {
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
    };
  };
}
