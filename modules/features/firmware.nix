# Firmware for a physical PC: the redistributable blobs that Wi-Fi, Bluetooth and GPU drivers
# load, and fwupd for device firmware updates (`fwupdmgr refresh && fwupdmgr update`).
{
  flake.modules.nixos.firmware = {
    hardware.enableRedistributableFirmware = true;
    services.fwupd.enable = true;
  };
}
