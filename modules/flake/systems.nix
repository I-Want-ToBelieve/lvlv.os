{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.modules];

  # Per-system outputs (checks, dev shell, formatter, apps) are built for these,
  # and a host's `system` must be one of them.
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
