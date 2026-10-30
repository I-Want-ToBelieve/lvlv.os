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
        # Keys are tried in order: the ed25519 key, then the RSA key it replaces, until the
        # new public key is registered with the service and the old one can be removed.
        withKeys = files: {
          IdentityFile = map (file: "~/.ssh/${file}") files;
          # Only these keys, not every key in the agent: GitHub logs in as the account of the
          # first key it accepts, which would pick the work account for github.com-personal.
          IdentitiesOnly = "yes";
          PreferredAuthentications = "publickey";
        };
        # GitHub's SSH endpoint on port 443, for networks that block port 22.
        githubWith = files:
          withKeys files
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
        "127.0.0.1" = withKeys ["id_rsa_gitlab_localhost"] // {Port = 10022;};
        "gitlab.com" = withKeys ["gitlab_id_ed25519" "id_rsa_gitlab"];
        "gitlab.maodouling.com" = withKeys ["id_ed25519" "id_rsa"] // {Port = 2224;};
        "github.com" = githubWith ["github_id_ed25519" "github_id_rsa"];
        "github.com-personal" = githubWith ["github_personal_id_ed25519"];
        "gitee.com" = withKeys ["gitee_id_ed25519" "gitee_id_rsa"];
        "001macos".HostName = "192.168.192.140";
      };
    };

    # kitty sets TERM=xterm-kitty, which most servers have no terminfo for. Inside kitty,
    # `kitten ssh` copies the terminfo over first; everywhere else ssh runs as it is.
    programs.fish.functions.ssh = {
      description = "ssh, through kitten ssh inside kitty";
      wraps = "ssh";
      body = ''
        if test "$TERM" = xterm-kitty; and type -q kitten
          kitten ssh $argv
        else
          command ssh $argv
        end
      '';
    };
    programs.zsh.initContent = ''
      ssh() {
        if [[ $TERM == xterm-kitty ]] && (( $+commands[kitten] )); then
          kitten ssh "$@"
        else
          command ssh "$@"
        fi
      }
    '';
  };
}
