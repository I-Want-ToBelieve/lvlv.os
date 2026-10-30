# Tiling windows: yabai, its keys (through the shortcuts feature), JankyBorders around windows and yakite layouts.
let
  yakite = "yakite action";
  bind = key: description: command: {inherit key description command;};
  hide = binding: binding // {hidden = true;};
  # Space 10 sits on the 0 key.
  digit = n:
    if n == 10
    then "0"
    else toString n;
in {
  flake.modules.darwin.yabai = {lib, ...}: {
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

    # Keys run through skhd; the shortcuts feature writes its config and the cheat sheet.
    lvlv.shortcuts.groups = {
      spaces = {
        title = "空间";
        order = 20;
        bindings =
          [
            (bind "ctrl - 1…0" "切换到空间 1–10" null)
            (bind "ctrl + shift - 1…0" "把窗口移到空间 1–10" null)
            (bind "ctrl + shift - j" "把窗口移到上一个空间" "yabai -m window --space prev")
            (bind "ctrl + shift - l" "把窗口移到下一个空间" "yabai -m window --space next")
          ]
          ++ lib.concatMap (n: [
            (hide (bind "ctrl - ${digit n}" "切换到空间 ${toString n}" "yabai -m space --focus ${toString n}"))
            (hide (bind "ctrl + shift - ${digit n}" "把窗口移到空间 ${toString n}" "yabai -m window --space ${toString n}"))
          ]) (lib.range 1 10);
      };

      windows = {
        title = "窗口";
        order = 30;
        bindings = [
          (bind "ctrl - k" "聚焦下一个窗口" "${yakite} focus-next-window")
          (bind "ctrl - i" "聚焦上一个窗口" "${yakite} focus-previous-window")
          (bind "ctrl + shift - k" "窗口和下一个位置交换" "${yakite} move-active-window-to-next-position")
          (bind "ctrl + shift - i" "窗口和上一个位置交换" "${yakite} move-active-window-to-previous-position")
          (bind "ctrl + shift - m" "窗口移到主区域最前" "${yakite} push-active-window-into-master-area-front")
          (bind "ctrl - f" "切换窗口浮动" "${yakite} toggle-active-window-floating")
          (bind "ctrl - x" "最小化窗口" "yabai -m window --minimize")
          (bind "ctrl - q" "关闭窗口" "yabai -m window --close")
        ];
      };

      layouts = {
        title = "布局";
        order = 40;
        bindings = [
          (bind "ctrl - t" "切换平铺布局" "${yakite} toggle-tile-layout")
          (bind "ctrl - m" "切换单窗口布局" "${yakite} toggle-monocle-layout")
          (bind "ctrl - 0x2A" "下一种布局" "${yakite} switch-to-next-layout")
          (bind "ctrl - j" "缩小主区域" "${yakite} decrease-layout-master-area-size")
          (bind "ctrl - l" "放大主区域" "${yakite} increase-layout-master-area-size")
        ];
      };
    };

    # Full names, so that Homebrew trusts these two formulae and not the whole tap.
    homebrew = {
      taps = ["I-Want-ToBelieve/homebrew-formulae"];
      brews = [
        "I-Want-ToBelieve/formulae/yakite"
        "I-Want-ToBelieve/formulae/yakite-toast"
      ];
    };
  };
}
