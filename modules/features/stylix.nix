# One colour scheme, wallpaper and set of fonts for the system and, through stylix's
# Home Manager integration, for every user's programs (kitty takes its font and opacity here).
{inputs, ...}: let
  theme = {pkgs, ...}: {
    stylix = {
      enable = true;
      image = pkgs.fetchurl {
        name = "cat_leaves.png";
        url = "https://raw.githubusercontent.com/I-Want-ToBelieve/wallpapers/main/catppuccin/cat_leaves.png";
        hash = "sha256-kegUK62YtI7G3P/pIqcWdFGlqN4S1/4xOOmOboPxJKE=";
      };
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      fonts = {
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        sansSerif = {
          package = pkgs.lxgw-wenkai;
          name = "LXGW WenKai Mono";
        };
        # CJK glyphs and Nerd Font icons in one monospace font.
        monospace = {
          package = pkgs.maple-mono.NF-CN;
          name = "Maple Mono NF CN";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
      opacity.terminal = 0.9;
    };
  };
in {
  flake.modules.darwin.stylix = {
    imports = [inputs.stylix.darwinModules.stylix theme];
  };

  flake.modules.nixos.stylix = {
    imports = [inputs.stylix.nixosModules.stylix theme];
  };

  flake.modules.homeManager.stylix = {
    # Targets for software this configuration does not use: gtk and gdu would write config
    # files nothing reads, and rofi's target still sets the renamed programs.rofi.font, which
    # warns on every evaluation.
    stylix.targets = {
      gtk.enable = false;
      gdu.enable = false;
      rofi.enable = false;
    };
  };
}
