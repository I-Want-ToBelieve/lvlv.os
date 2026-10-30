{
  flake.modules.homeManager.ssh = {
    lib,
    pkgs,
    ...
  }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      # Each name opens a `Host` block; values use OpenSSH's own directive names.
      settings = let
        withKey = file: {
          IdentityFile = "~/.ssh/${file}";
          PreferredAuthentications = "publickey";
        };
        # GitHub's SSH endpoint on port 443, for networks that block port 22.
        githubWith = file:
          withKey file
          // {
            HostName = "ssh.github.com";
            Port = 443;
          };
      in {
        "*" =
          {
            StrictHostKeyChecking = "accept-new";
            # A key's passphrase is asked for once per login session, not on every connection.
            AddKeysToAgent = "yes";
            # Keep idle connections through NAT and notice dead ones within three minutes.
            ServerAliveInterval = 60;
            ServerAliveCountMax = 3;
            # Later connections to the same host reuse the first one's TCP connection.
            ControlMaster = "auto";
            ControlPath = "~/.ssh/control-%C";
            ControlPersist = "10m";
          }
          # Passphrases kept in the macOS Keychain; Linux's OpenSSH rejects this option.
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {UseKeychain = "yes";};
        # GitLab running on this machine.
        "127.0.0.1" = withKey "id_rsa_gitlab_localhost" // {Port = 10022;};
        "gitlab.com" = withKey "id_rsa_gitlab";
        "gitlab.maodouling.com" = withKey "id_rsa" // {Port = 2224;};
        "github.com" = githubWith "github_id_rsa";
        "github.com-personal" = githubWith "github_personal_id_rsa";
        "gitee.com" = withKey "gitee_id_rsa";
        "001macos".HostName = "192.168.192.140";
      };
    };
  };
}
