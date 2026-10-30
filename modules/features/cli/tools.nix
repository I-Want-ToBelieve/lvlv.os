{
  flake.modules.homeManager.cli-tools = {pkgs, ...}: {
    home.packages = [
      pkgs.aria2
      pkgs.bandwhich
      pkgs.bc
      pkgs.btop
      pkgs.duf
      pkgs.dust
      pkgs.fd
      pkgs.ffmpeg
      pkgs.hyperfine
      # A JSON viewer with folding and search.
      pkgs.jless
      pkgs.jq
      pkgs.krabby
      pkgs.lazygit
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

    programs = {
      # Searchable shell history behind Ctrl-R in every shell; the Up arrow keeps the
      # shell's own history.
      atuin = {
        enable = true;
        flags = ["--disable-up-arrow"];
        settings.update_check = false;
      };
      bat.enable = true;
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
