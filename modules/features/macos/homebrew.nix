# Homebrew itself is installed by hand (https://brew.sh); nix-darwin declares what it installs.
# Features that need a formula or cask add it to these lists themselves (see yabai, phoenix).
{
  flake.modules.darwin.homebrew = {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = false;
        # Uninstall, with their files, all formulae and casks not declared in this flake.
        cleanup = "zap";
      };
      taps = [
        "v2raya/v2raya"
        "jackmordaunt/homebrew-tap"
        "oven-sh/bun"
      ];
      brews = [
        # nixpkgs' curl does not work well on macOS.
        "curl"
        "wget"
        "v2raya/v2raya/v2raya"
        "clang-format"
        "mas"
        "rust"
        "node"
        "fnm"
        "pnpm"
        "yazi"
        "icnsify"
        # Installed by hand before; declared so that cleanup keeps them.
        "act"
        "oven-sh/bun/bun"
        "rclone"
        "uv"
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
        # Installed by hand before; declared so that cleanup keeps them.
        "android-platform-tools"
        "claude-code"
        "font-maple-mono-nf-cn"
        "mitmproxy"
        "openmtp"
        "orbstack"
      ];
    };

    # Homebrew mirrors in China.
    environment.variables = {
      HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
      HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
      HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
      HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
      HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
    };
  };
}
