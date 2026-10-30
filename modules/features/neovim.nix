{
  flake.modules.homeManager.neovim = {
    # $EDITOR, also run as vi and vim; stylix gives it the colour scheme.
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      # No plugin here needs a Ruby or Python host.
      withRuby = false;
      withPython3 = false;
    };
  };
}
