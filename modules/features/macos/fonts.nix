{
  flake.modules.darwin.fonts = {pkgs, ...}: {
    # Icon fonts; the text fonts come from stylix.
    fonts.packages = [
      pkgs.material-design-icons
      pkgs.font-awesome
    ];
  };
}
