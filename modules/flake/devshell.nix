# Development shell. Entering it links the selected nix-skills, pinned by flake.lock, into the
# project's agent skill directories: .claude/skills (Claude Code) and .agents/skills (Codex).
{
  lib,
  config,
  inputs,
  ...
}: let
  catalog = lib.importJSON "${inputs.nix-skills}/skills.json";
  skills = config.lvlv.agentSkills;
in {
  options.lvlv.agentSkills = lib.mkOption {
    type = lib.types.listOf (lib.types.enum catalog);
    default = [
      "nix-language"
      "nix-workflow"
      "nixos-operations"
      "nixos-wiki"
      "nixpkgs-development"
      "nix-darwin"
      "home-manager"
    ];
    description = "nix-skills linked for coding agents working in this repository.";
  };

  config.perSystem = {
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShellNoCC {
      packages = [
        config.treefmt.build.wrapper
        # Editing secrets (see the secrets feature).
        pkgs.age
        pkgs.sops
        pkgs.ssh-to-age
      ];

      shellHook = ''
        # The age key, encrypted with a passphrase that sops asks for on each use; the same
        # path on both systems (sops' default is under ~/Library/Application Support on macOS).
        export SOPS_AGE_KEY_FILE=''${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.age}

        link_skills() {
          local dir=$1 link target name
          mkdir -p "$dir"
          # Drop links into any nix-skills checkout that are no longer selected; leave the rest alone.
          for link in "$dir"/*; do
            [ -L "$link" ] || continue
            target=$(readlink "$link")
            [ -f "''${target%/skills/*}/skills.json" ] || continue
            case " ${toString skills} " in
              *" ''${link##*/} "*) ;;
              *) rm -- "$link" ;;
            esac
          done
          for name in ${lib.escapeShellArgs skills}; do
            if [ -e "$dir/$name" ] && [ ! -L "$dir/$name" ]; then
              echo "nix-skills: $dir/$name is not a link; left alone" >&2
            else
              ln -sfn "${inputs.nix-skills}/skills/$name" "$dir/$name"
            fi
          done
        }
        root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
        link_skills "$root/.claude/skills"
        link_skills "$root/.agents/skills"
      '';
    };
  };
}
