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
    inputs',
    ...
  }: {
    apps.activate = {
      type = "app";
      meta.description = "Switch a lvlv.os host to this flake";
      program = lib.getExe (pkgs.writeShellApplication {
        name = "activate";
        runtimeInputs =
          lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.nixos-rebuild-ng) pkgs.nixos-rebuild-ng
          ++ lib.optional pkgs.stdenv.hostPlatform.isDarwin inputs'.nix-darwin.packages.darwin-rebuild;
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
            darwin) exec sudo darwin-rebuild switch --flake "${self}#$host" "$@" ;;
            nixos) exec nixos-rebuild switch --flake "${self}#$host" --sudo "$@" ;;
          esac
        '';
      });
    };
  };
}
