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
      pkgs.fzf
      pkgs.httpie
      pkgs.hyperfine
      pkgs.krabby
      pkgs.lazygit
      pkgs.openssl
      pkgs.ripgrep
      pkgs.rsync
      pkgs.xh
      pkgs.xz
    ];

    programs = {
      bat.enable = true;
      eza.enable = true;
      mcfly.enable = true;
      # LS_COLORS for every shell, generated from the stylix colour scheme.
      vivid.enable = true;
      zellij.enable = true;
      zoxide.enable = true;
    };
  };
}
