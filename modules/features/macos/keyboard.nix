{
  flake.modules.darwin.macos-keyboard = {
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
      # Swap left Control (HID 0x7000000E0) and left Command (HID 0x7000000E3).
      # Values generated with https://hidutil-generator.netlify.app/
      userKeyMapping = [
        {
          HIDKeyboardModifierMappingSrc = 30064771296;
          HIDKeyboardModifierMappingDst = 30064771299;
        }
        {
          HIDKeyboardModifierMappingSrc = 30064771299;
          HIDKeyboardModifierMappingDst = 30064771296;
        }
      ];
    };
  };
}
