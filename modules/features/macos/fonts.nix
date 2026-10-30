{
  flake.modules.darwin.fonts = {pkgs, ...}: {
    # The text fonts of the colour scheme come from stylix.
    fonts.packages = [
      pkgs.material-design-icons
      pkgs.font-awesome
      # Monospace with CJK glyphs and Nerd Font icons.
      pkgs.maple-mono.NF-CN
    ];
  };
}
