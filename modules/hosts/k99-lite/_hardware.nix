# k99-lite: Intel desktop. LUKS ("cryptroot") holds LVM with btrfs subvolumes and swap;
# GRUB also boots Windows (os-prober) and macOS through OpenCore.
{
  pkgs,
  modulesPath,
  ...
}: let
  subvolume = name: {
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
    options = ["subvol=${name}" "compress=zstd" "noatime"];
  };
in {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel"];
    # Kept from the previous configuration of this machine.
    kernelParams = ["pcie_aspm=off"];
    supportedFilesystems = ["ntfs"];
    initrd = {
      availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "nvme" "usb_storage"];
      kernelModules = ["dm-snapshot"];
      luks.devices.luksroot = {
        device = "/dev/disk/by-label/cryptroot";
        allowDiscards = true;
      };
    };
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 5;
        extraEntries = ''
          menuentry "OpenCore (macOS)" {
            insmod chain
            insmod fat
            insmod part_gpt
            search --label --no-floppy --set=root DARWIN-BOOT
            chainloader ($root)/EFI/BOOT/BOOTx64.efi
          }
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
    };
  };

  fileSystems = {
    "/" = subvolume "root";
    "/home" = subvolume "home";
    "/nix" = subvolume "nix";
    "/var/log" = subvolume "log" // {neededForBoot = true;};
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };
  swapDevices = [{device = "/dev/disk/by-label/swap";}];
  services.btrfs.autoScrub.enable = true;

  # Windows on the same machine keeps the hardware clock in local time.
  time.hardwareClockInLocalTime = true;
}
