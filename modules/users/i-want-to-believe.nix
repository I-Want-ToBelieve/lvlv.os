let
  name = "i.want.to.believe";
in {
  flake.modules.nixos.i-want-to-believe = {
    users.users.${name} = {
      description = "I Want To Believe";
      isNormalUser = true;
      # Matches the owner of the existing home directory.
      uid = 1000;
      extraGroups = ["wheel" "networkmanager" "systemd-journal"];
    };
  };

  # nix-darwin leaves this account alone (it is not in users.knownUsers), so its login shell
  # is set once with chsh; Home Manager only needs to know the home directory.
  flake.modules.darwin.i-want-to-believe = {
    users.users.${name}.home = "/Users/${name}";
  };
}
