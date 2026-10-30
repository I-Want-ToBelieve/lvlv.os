{
  flake.modules.homeManager.nushell = {
    lib,
    pkgs,
    ...
  }: {
    programs.nushell = {
      enable = true;
      # Same environment as the other shells, including home.sessionPath.
      loadSessionVariables = true;
      settings.edit_mode = "vi";
      extraConfig = "^${lib.getExe pkgs.krabby} random";
    };
  };
}
