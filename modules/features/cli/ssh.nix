{
  flake.modules.homeManager.ssh = {
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
        "*".StrictHostKeyChecking = "accept-new";
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
