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
      # Colours come from stylix. The key bindings stay off so that Ctrl-R remains atuin's.
      fzf = {
        enable = true;
        enableBashIntegration = false;
        enableZshIntegration = false;
        enableFishIntegration = false;
        enableNushellIntegration = false;
        defaultOptions = ["--prompt 'λ '" "--pointer 'λ'"];
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
      zoxide.enable = true;
    };
  };
}
