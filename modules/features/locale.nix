let
  timeZone = {time.timeZone = "Asia/Shanghai";};
in {
  flake.modules.nixos.locale = {
    imports = [timeZone];
    i18n.extraLocales = ["zh_CN.UTF-8/UTF-8"];
  };

  flake.modules.darwin.locale = timeZone;
}
