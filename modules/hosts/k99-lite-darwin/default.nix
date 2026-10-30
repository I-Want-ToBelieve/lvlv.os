let
  user = "i.want.to.believe";
in {
  lvlv.hosts.k99-lite-darwin = {
    class = "darwin";
    system = "aarch64-darwin";
    # The nix-darwin state this Mac was set up with; never change it.
    stateVersion = 5;
    profiles = ["desktop"];
    features = ["i-want-to-believe"];
    modules = [{system.primaryUser = user;}];
    home.${user} = {
      stateVersion = "24.05";
      profiles = ["cli" "desktop"];
    };
  };
}
