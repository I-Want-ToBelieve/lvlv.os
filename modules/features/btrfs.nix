# Upkeep for a system on btrfs: a monthly scrub to find corrupted blocks while the other
# copy can still repair them, and hourly snapshots of /home to restore deleted or
# overwritten files from (`snapper -c home list`, files under /home/.snapshots/<n>/snapshot).
{
  flake.modules.nixos.btrfs = {lib, ...}: {
    services.btrfs.autoScrub = {
      enable = true;
      # Every subvolume of a filesystem is scrubbed at once, so one mount point suffices.
      fileSystems = lib.mkDefault ["/"];
    };

    services.snapper.configs.home = {
      SUBVOLUME = "/home";
      ALLOW_GROUPS = ["wheel"];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 24;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 3;
      TIMELINE_LIMIT_YEARLY = 0;
    };
    # snapper keeps its snapshots in this subvolume but does not create it; `v` makes a
    # btrfs subvolume when the path does not exist yet.
    systemd.tmpfiles.rules = ["v /home/.snapshots 0750 root wheel -"];
  };
}
