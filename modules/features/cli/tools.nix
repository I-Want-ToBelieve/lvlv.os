{
  flake.modules.homeManager.cli-tools = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = [
      pkgs.aria2
      pkgs.bandwhich
      pkgs.bc
      pkgs.duf
      pkgs.dust
      pkgs.fd
      pkgs.ffmpeg
      pkgs.hyperfine
      # A JSON viewer with folding and search.
      pkgs.jless
      pkgs.jq
      pkgs.krabby
      pkgs.openssl
      # Packs and unpacks every common archive format.
      pkgs.ouch
      pkgs.procs
      pkgs.rclone
      pkgs.ripgrep
      pkgs.rsync
      pkgs.wget
      # HTTP client with httpie's syntax.
      pkgs.xh
      pkgs.xz
      pkgs.yq-go
    ];

    # The variables `batman --export-env` prints, except that batman starts with the bash its
    # shebang names rather than the first bash on PATH.
    home.sessionVariables = {
      MANPAGER = "env BATMAN_IS_BEING_MANPAGER=yes ${lib.getExe pkgs.bat-extras.batman}";
      MANROFFOPT = "-c";
    };

    programs = {
      # Searchable shell history behind Ctrl-R in every shell; the Up arrow keeps the
      # shell's own history.
      atuin = {
        enable = true;
        flags = ["--disable-up-arrow"];
        settings = {
          update_check = false;
          # The search starts in the vi mode the shell was in, with fish's cursor for that mode.
          keymap_mode = "auto";
          keymap_cursor = {
            vim_insert = "steady-bar";
            vim_normal = "steady-block";
          };
        };
      };
      bat = {
        enable = true;
        # Man pages through bat, in its stylix colours (MANPAGER above).
        extraPackages = [pkgs.bat-extras.batman];
      };
      # Enabled here rather than listed as a package so that stylix themes it. btop.conf is
      # then read-only, so the settings once changed in btop's own menu are kept here.
      btop = {
        enable = true;
        settings = {
          update_ms = 1000;
          proc_sorting = "memory";
          proc_tree = true;
          net_auto = false;
        };
      };
      # Its ls, ll, la, lt and lla aliases carry these options in every shell.
      eza = {
        enable = true;
        icons = "auto";
        git = true;
        extraOptions = ["--group-directories-first"];
      };
      # Colours come from stylix. Ctrl-T picks a file and Alt-C a directory to go to;
      # Ctrl-R stays atuin's.
      fzf = {
        enable = true;
        defaultOptions = ["--prompt 'λ '" "--pointer 'λ'"];
        fileWidget.options = ["--preview 'bat --color=always --style=plain {}'"];
        historyWidget.command = "";
      };
      # `tldr <command>`: short examples.
      tealdeer = {
        enable = true;
        settings.updates.auto_update = true;
      };
      # LS_COLORS for every shell, generated from the stylix colour scheme.
      vivid.enable = true;
      # `ra` opens yazi and moves the shell to the directory yazi was left in.
      yazi = {
        enable = true;
        shellWrapperName = "ra";
      };
      zellij.enable = true;
      # `cd` itself learns the directories visited and jumps to them by part of the name;
      # `cdi` picks one interactively.
      zoxide = {
        enable = true;
        options = ["--cmd" "cd"];
      };
    };
  };
}
