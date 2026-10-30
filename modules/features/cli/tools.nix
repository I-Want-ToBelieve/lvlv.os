{
  flake.modules.homeManager.cli-tools = {pkgs, ...}: {
    home.packages = [
      pkgs.aria2
      pkgs.bandwhich
      pkgs.bc
      pkgs.bottom
      pkgs.btop
      pkgs.duf
      pkgs.dust
      pkgs.fd
      pkgs.ffmpeg
      pkgs.httpie
      pkgs.hyperfine
      pkgs.krabby
      pkgs.lazygit
      pkgs.openssl
      pkgs.rclone
      pkgs.ripgrep
      pkgs.rsync
      pkgs.wget
      pkgs.xh
      pkgs.xz
    ];

    programs = {
      bat.enable = true;
      # Its ls, ll, la, lt and lla aliases carry these options in every shell.
      eza = {
        enable = true;
        icons = "auto";
        git = true;
        extraOptions = ["--group-directories-first"];
      };
      # Colours come from stylix. The key bindings stay off so that Ctrl-R remains mcfly's.
      fzf = {
        enable = true;
        enableBashIntegration = false;
        enableZshIntegration = false;
        enableFishIntegration = false;
        enableNushellIntegration = false;
        defaultOptions = ["--prompt 'λ '" "--pointer 'λ'"];
      };
      mcfly.enable = true;
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
