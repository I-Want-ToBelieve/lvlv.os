# Secrets kept in the repository encrypted with sops, decrypted on the host at activation
# into /run/secrets. A host decrypts with its own SSH host key, so it needs no extra key.
#
# Adding the first secret (in the devShell, which has sops and ssh-to-age; your own age key
# is ~/.config/sops/age/keys.age, passphrase-protected, and already listed in .sops.yaml):
#   1. on the host: ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub    its age recipient
#   2. add it to .sops.yaml, then `sops secrets/<host>.yaml`
#   3. in the host: sops.defaultSopsFile = ../../../secrets/<host>.yaml; sops.secrets.<name> = {};
{inputs, ...}: {
  flake.modules.nixos.secrets = {
    imports = [inputs.sops-nix.nixosModules.sops];
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
