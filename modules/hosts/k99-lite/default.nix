{inputs, ...}: let
  user = "i.want.to.believe";
in {
  lvlv.hosts.k99-lite = {
    class = "nixos";
    system = "x86_64-linux";
    # The release k99-lite was installed with; never change it.
    stateVersion = "24.05";
    profiles = ["minimal"];
    features = ["root" "i-want-to-believe" "fish" "stylix" "btrfs" "firmware"];
    modules = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      ./_hardware.nix
      ({pkgs, ...}: {users.users.${user}.shell = pkgs.fish;})
    ];
    # The same command-line environment as on macOS, which this machine also boots.
    home.${user} = {
      stateVersion = "24.05";
      profiles = ["cli"];
    };
  };
}
