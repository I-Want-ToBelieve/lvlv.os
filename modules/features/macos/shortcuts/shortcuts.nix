# Global hotkeys in one place. Features add groups of bindings to `lvlv.shortcuts`; from them
# this feature writes the skhd config and the cheat sheet that KeyHint shows for the frontmost
# app (the toggle key below). With Accessibility permission KeyHint also lists the app's menu
# bar shortcuts, so only shortcuts that are not in a menu need writing down here.
{
  flake.modules.darwin.shortcuts = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types;
    cfg = config.lvlv.shortcuts;
    keyhint = pkgs.callPackage ./_keyhint.nix {};

    binding = types.submodule {
      options = {
        key = mkOption {
          type = types.str;
          example = "ctrl + shift - k";
          description = "Key in skhd syntax, which KeyHint also reads.";
        };
        description = mkOption {
          type = types.str;
          description = "What the key does, as the cheat sheet shows it.";
        };
        command = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Command skhd runs. Null documents a key that the app itself handles.";
        };
        hidden = mkOption {
          type = types.bool;
          default = false;
          description = "Leave the key out of the cheat sheet, for runs of keys that one documented entry sums up.";
        };
      };
    };

    group = types.submodule ({name, ...}: {
      options = {
        title = mkOption {
          type = types.str;
          default = name;
          description = "Heading of the group in the cheat sheet.";
        };
        app = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "kitty";
          description = "Process name of the app the group belongs to (as skhd matches it); null for keys that work everywhere.";
        };
        order = mkOption {
          type = types.int;
          default = 100;
          description = "Position among the groups, lowest first.";
        };
        bindings = mkOption {
          type = types.listOf binding;
          default = [];
          description = "The keys of the group.";
        };
      };
    });

    groups = lib.sort (a: b: a.order < b.order) (lib.attrValues cfg.groups);

    commands = lib.concatMap (g:
      map (b: b // {inherit (g) app;}) (lib.filter (b: b.command != null) g.bindings))
    groups;
    byKey = lib.groupBy (b: b.key) commands;

    # skhd allows one definition per key, so app-specific commands for the same key share a
    # process list, with the global command (if any) as its `*` fallback.
    skhdLine = key: bindings: let
      perApp = lib.filter (b: b.app != null) bindings;
      global = lib.filter (b: b.app == null) bindings;
    in
      if perApp == []
      then "${key} : ${(lib.head global).command}"
      else
        lib.concatStringsSep "\n" (
          ["${key} ["]
          ++ map (b: "  \"${b.app}\" : ${b.command}") perApp
          ++ map (b: "  * : ${b.command}") global
          ++ ["]"]
        );

    clashes = lib.filterAttrs (_: bindings: let
      targets = map (b: b.app) bindings;
    in
      lib.length targets != lib.length (lib.unique targets))
    byKey;

    hints = pkgs.writeText "keyhint.json" (builtins.toJSON {
      inherit (cfg) toggleKey;
      groups = lib.filter (g: g.bindings != []) (map (g: {
          inherit (g) title app;
          bindings = map (b: {inherit (b) key description;}) (lib.filter (b: !b.hidden) g.bindings);
        })
        groups);
    });
  in {
    options.lvlv.shortcuts = {
      toggleKey = mkOption {
        type = types.str;
        # ctrl + ?, which no app here uses.
        default = "ctrl + shift - 0x2C";
        description = "Key, in skhd syntax, that shows or hides the cheat sheet.";
      };
      groups = mkOption {
        type = types.attrsOf group;
        default = {};
        description = "Groups of hotkeys, by name.";
      };
    };

    config = {
      assertions = [
        {
          assertion = clashes == {};
          message = "lvlv.shortcuts: more than one command for the same app on ${lib.concatStringsSep ", " (lib.attrNames clashes)}";
        }
      ];

      lvlv.shortcuts.groups.general = {
        title = "常用";
        order = 10;
        bindings = [
          {
            key = cfg.toggleKey;
            description = "显示快捷键";
            command = "${lib.getExe keyhint} toggle";
          }
          {
            key = "ctrl - return";
            description = "打开 kitty";
            command = "kitty --single-instance -d ~";
          }
          {
            key = "cmd - backspace";
            description = "打开启动器（⌥ Space）";
            command = ''skhd -k "alt - space"'';
          }
          {
            key = "ctrl - w";
            description = "调度中心";
            command = ''skhd -k "ctrl - up"'';
          }
        ];
      };

      services.skhd = {
        enable = true;
        skhdConfig = lib.concatStringsSep "\n" (lib.mapAttrsToList skhdLine byKey) + "\n";
      };

      environment.systemPackages = [keyhint];

      launchd.user.agents.keyhint.serviceConfig = {
        # The binary inside the bundle, so that macOS sees KeyHint.app and its Info.plist.
        ProgramArguments = ["${keyhint}/Applications/KeyHint.app/Contents/MacOS/KeyHint" "--config" "${hints}"];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
      };
    };
  };
}
