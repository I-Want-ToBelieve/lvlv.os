# Tiling windows: yabai, keys from skhd, JankyBorders around windows and yakite layouts.
let
  yakite = "yakite action";
in {
  flake.modules.darwin.yabai = {
    services.yabai = {
      enable = true;
      enableScriptingAddition = true;
      config = {
        focus_follows_mouse = "off";
        mouse_follows_focus = "off";
      };
      extraConfig = ''
        yakite-daemon 2>/dev/null 1>&2 &
      '';
    };

    # A launchd agent; stylix sets the active and inactive colours.
    services.jankyborders = {
      enable = true;
      width = 12.0;
    };

    services.skhd = {
      enable = true;
      skhdConfig = ''
        ctrl - return : kitty --single-instance -d ~
        cmd - backspace : skhd -k "alt - space"
        ctrl - w : skhd -k "ctrl - up"

        ctrl - 1 : yabai -m space --focus 1
        ctrl - 2 : yabai -m space --focus 2
        ctrl - 3 : yabai -m space --focus 3
        ctrl - 4 : yabai -m space --focus 4
        ctrl - 5 : yabai -m space --focus 5
        ctrl - 6 : yabai -m space --focus 6
        ctrl - 7 : yabai -m space --focus 7
        ctrl - 8 : yabai -m space --focus 8
        ctrl - 9 : yabai -m space --focus 9
        ctrl - 0 : yabai -m space --focus 10

        ctrl + shift - j : yabai -m window --space prev
        ctrl + shift - l : yabai -m window --space next
        ctrl + shift - 1 : yabai -m window --space 1
        ctrl + shift - 2 : yabai -m window --space 2
        ctrl + shift - 3 : yabai -m window --space 3
        ctrl + shift - 4 : yabai -m window --space 4
        ctrl + shift - 5 : yabai -m window --space 5
        ctrl + shift - 6 : yabai -m window --space 6
        ctrl + shift - 7 : yabai -m window --space 7
        ctrl + shift - 8 : yabai -m window --space 8
        ctrl + shift - 9 : yabai -m window --space 9
        ctrl + shift - 0 : yabai -m window --space 10

        ctrl - q : yabai -m window --close
        ctrl - x : yabai -m window --minimize

        ctrl - t : ${yakite} toggle-tile-layout
        ctrl - m : ${yakite} toggle-monocle-layout
        ctrl - f : ${yakite} toggle-active-window-floating
        ctrl - k : ${yakite} focus-next-window
        ctrl - i : ${yakite} focus-previous-window
        ctrl + shift - k : ${yakite} move-active-window-to-next-position
        ctrl + shift - i : ${yakite} move-active-window-to-previous-position
        ctrl + shift - m : ${yakite} push-active-window-into-master-area-front
        ctrl - 0x2A : ${yakite} switch-to-next-layout
        ctrl - j : ${yakite} decrease-layout-master-area-size
        ctrl - l : ${yakite} increase-layout-master-area-size
      '';
    };

    homebrew = {
      taps = ["I-Want-ToBelieve/homebrew-formulae"];
      brews = [
        "yakite"
        "yakite-toast"
      ];
    };
  };
}
