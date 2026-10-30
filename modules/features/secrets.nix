# Secrets kept in the repository encrypted with sops, decrypted on the host at activation
# into /run/secrets. A host decrypts with its own SSH host key, so it needs no extra key.
#
# Adding the first secret (in the devShell, which has sops and ssh-to-age):
#   1. ssh-keyscan -t ed25519 <host> | ssh-to-age       the host's age recipient
#   2. age-keygen -o ~/.config/sops/age/keys.txt        your own key, to edit the files
#   3. list both public keys in .sops.yaml, then `sops secrets/<host>.yaml`
#   4. in the host: sops.defaultSopsFile = ./secrets/<host>.yaml; sops.secrets.<name> = {};
{inputs, ...}: {
  flake.modules.nixos.secrets = {
    imports = [inputs.sops-nix.nixosModules.sops];
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
