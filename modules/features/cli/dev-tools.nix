# Development tools and language toolchains on PATH in every shell, pinned by flake.lock.
# Projects that need other versions bring them through their own devShell (direnv) or fnm.
{
  flake.modules.homeManager.dev-tools = {
    config,
    lib,
    pkgs,
    ...
  }: let
    home = config.home.homeDirectory;
    fnm = lib.getExe pkgs.fnm;
  in {
    home.packages = [
      # Run GitHub Actions workflows locally.
      pkgs.act
      # adb and fastboot.
      pkgs.android-tools
      # clang-format, clangd and clang-tidy.
      pkgs.clang-tools
      # Diffs by syntax tree: `difft a b`, or `git -c diff.external=difft diff`.
      pkgs.difftastic
      pkgs.just
      pkgs.lazydocker
      pkgs.mitmproxy
      pkgs.watchexec
      # Node.js
      pkgs.nodejs
      pkgs.pnpm
      pkgs.fnm
      # Python
      pkgs.uv
      # Rust
      pkgs.cargo
      pkgs.rustc
      pkgs.clippy
      pkgs.rustfmt
      pkgs.rust-analyzer
    ];

    home.sessionVariables = {
      # The Nix store is read-only, so `npm install -g` goes to ~/.npm/bin (on PATH via shell-env).
      NPM_CONFIG_PREFIX = "${home}/.npm";
      # Where `pnpm add -g` puts packages and their commands; the directory `pnpm setup` uses.
      PNPM_HOME =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "${home}/Library/pnpm"
        else "${home}/.local/share/pnpm";
    };
    home.sessionPath = [config.home.sessionVariables.PNPM_HOME];

    # A Node version chosen with fnm, or by a project's .node-version / .nvmrc, comes before
    # the Nix one on PATH; with none chosen, `node` is the Nix one.
    programs.fish.interactiveShellInit = "${fnm} env --use-on-cd --shell fish | source";
    programs.zsh.initContent = ''eval "$(${fnm} env --use-on-cd --shell zsh)"'';
  };
}
