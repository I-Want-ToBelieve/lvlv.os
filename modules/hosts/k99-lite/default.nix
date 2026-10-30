{inputs, ...}: {
  lvlv.hosts.k99-lite = {
    class = "nixos";
    system = "x86_64-linux";
    # The release k99-lite was installed with; never change it.
    stateVersion = "24.05";
    profiles = ["minimal"];
    features = ["root" "i-want-to-believe"];
    modules = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      ./_hardware.nix
    ];
  };
}
