# Remote administration over OpenSSH with public keys only, root included.
{
  flake.modules.nixos.ssh-server = {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
