{
  flake.modules.nixos.networking = {
    networking.networkmanager.enable = true;
    # Do not hold the boot until the network is up.
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
