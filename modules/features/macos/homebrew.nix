# Homebrew itself is installed by hand (https://brew.sh); nix-darwin declares what it installs.
# Features that need a formula or cask add it to these lists themselves (see yabai, phoenix).
# Tools that nixpkgs ships come from Nix instead.
#
# Homebrew refuses to load formulae from taps it does not trust, which aborts activation.
# Formulae from third-party taps are therefore written in full (user/repo/formula): only
# then does nix-darwin's `trusted: true` apply, to that formula alone.
let
  # Homebrew mirrors in China.
  mirrors = {
    HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };
in {
  flake.modules.darwin.homebrew = {pkgs, ...}: {
    homebrew = {
      enable = true;
      onActivation = {
        # Fetch the formula index and upgrade what is installed, so that Homebrew's packages do
        # not stay at the versions they were first installed with.
        autoUpdate = true;
        upgrade = true;
        # Uninstall, with their files, all formulae and casks not declared in this flake.
        cleanup = "zap";
        # darwin-rebuild runs brew through sudo, which does not pass the shell's variables on.
        extraEnv = mirrors;
      };
      taps = ["jackmordaunt/homebrew-tap"];
      brews = [
        # nixpkgs' curl does not work well on macOS.
        "curl"
        "jackmordaunt/tap/icnsify"
      ];
      casks = [
        "firefox"
        "google-chrome"
        "raycast"
        "alt-tab"
        "copyq"
        "maccy"
        "monitorcontrol"
        "easy-move+resize"
        "hackintool"
        "kap"
        "keycastr"
        "snipaste"
        "switchhosts"
        "termius"
        "zerotier-one"
        "logitech-g-hub"
        "claude-code"
        "openmtp"
        "orbstack"
      ];
    };

    environment.variables = mirrors;

    # The Mac App Store command line.
    environment.systemPackages = [pkgs.mas];
  };
}
