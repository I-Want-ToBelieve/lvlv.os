# Graphical apps from nixpkgs. Apps that are better installed as casks live in the homebrew feature.
{
  flake.modules.homeManager.gui-apps = {pkgs, ...}: {
    home.packages = [
      pkgs.flameshot
      pkgs.iina
      pkgs.localsend
      pkgs.scrcpy
      pkgs.vscode
    ];
  };
}
