# One command switches any host, whichever OS it runs (after nixos-unified's `activate`):
#   nix run .#activate                  this machine, chosen by its hostname
#   nix run .#activate -- <host> [...]  extra arguments go to darwin-rebuild / nixos-rebuild, e.g.
#                                       --target-host root@k99-lite --build-host root@k99-lite
#                                       deploys over SSH and builds on the target
{
  lib,
  config,
  self,
  ...
}: let
  inherit (config.lvlv) hosts;
in {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    apps.activate = {
      type = "app";
      meta.description = "Switch a lvlv.os host to this flake";
      program = lib.getExe (pkgs.writeShellApplication {
        name = "activate";
        runtimeInputs =
          lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.nixos-rebuild-ng) pkgs.nixos-rebuild-ng
          # Built from this flake's pkgs rather than nix-darwin's own package set, which on
          # Intel Macs would lack the nixpkgs.config that keeps 26.05 quiet.
          ++ lib.optional pkgs.stdenv.hostPlatform.isDarwin
          (pkgs.callPackage "${(config.lvlv.inputsFor system).nix-darwin}/pkgs/nix-tools" {}).darwin-rebuild;
        text = ''
          host=''${1:-$(hostname -s)}
          [ $# -gt 0 ] && shift
          case "$host" in
            ${lib.concatStrings (lib.mapAttrsToList (name: host: "${name}) class=${host.class} ;;\n") hosts)}
            *)
              echo "activate: unknown host '$host'; known hosts: ${lib.concatStringsSep ", " (lib.attrNames hosts)}" >&2
              exit 1
              ;;
          esac
          case "$class" in
            darwin)
              old=$(readlink -f /run/current-system)
              sudo darwin-rebuild switch --flake "${self}#$host" "$@"
              new=$(readlink -f /run/current-system)
              # The shortcuts feature's KeyHint shows what the switch changed, where installed.
              if [ "$old" != "$new" ] && command -v keyhint >/dev/null; then
                diff=$(mktemp)
                nix store diff-closures "$old" "$new" >"$diff" 2>/dev/null || true
                nohup keyhint changes "$old" "$new" "$diff" >/dev/null 2>&1 &
              fi
              ;;
            nixos) exec nixos-rebuild switch --flake "${self}#$host" --sudo "$@" ;;
          esac
        '';
      });
    };
  };
}
