# A NixOS system that boots, reaches the network and can be administered over SSH; nothing else.
{
  lvlv.profiles.nixos.minimal = [
    "nix"
    "locale"
    "networking"
    "ssh-server"
    "secrets"
    "zram"
  ];
}
