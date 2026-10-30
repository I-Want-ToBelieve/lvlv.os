# Phoenix window manager scripting: the app from Homebrew, its script from Home Manager.
{
  flake.modules.darwin.phoenix = {
    homebrew.casks = ["phoenix"];
  };

  flake.modules.homeManager.phoenix = {
    home.file.".phoenix.js".source = ./phoenix.js;
  };
}
