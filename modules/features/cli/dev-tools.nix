{
  flake.modules.homeManager.dev-tools = {pkgs, ...}: {
    home.packages = [
      # Run GitHub Actions workflows locally.
      pkgs.act
      # adb and fastboot.
      pkgs.android-tools
      # clang-format, clangd and clang-tidy.
      pkgs.clang-tools
      pkgs.mitmproxy
      pkgs.uv
    ];
  };
}
