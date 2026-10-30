{
  flake.modules.nixos.zram = {
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };
  };
}
