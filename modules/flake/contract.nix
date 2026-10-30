# The Feature / Profile / Host contract (AGENTS.md explains it in prose).
#
# Feature  `flake.modules.<class>.<name>`, where class is nixos, darwin or homeManager.
#          One file may define the same feature for several classes. Features never name a host.
# Profile  `lvlv.profiles.<class>.<name>`: a named list of features of one class.
# Host     `lvlv.hosts.<name>`: the only place a system is assembled. This file turns every
#          host into a nixosConfigurations / darwinConfigurations entry and a check.
#
# Feature and profile names are enums of what is defined, so a typo fails evaluation and
# lists the valid names.
{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;

  cfg = config.lvlv;
  features = config.flake.modules;
  flakeSystems = config.systems;

  featureNamed = class: types.enum (lib.attrNames (features.${class} or {}));
  profileNamed = class: types.enum (lib.attrNames cfg.profiles.${class});

  selection = class: {
    profiles = mkOption {
      type = types.listOf (profileNamed class);
      default = [];
      description = "Profiles to apply.";
    };
    features = mkOption {
      type = types.listOf (featureNamed class);
      default = [];
      description = "Features to apply on top of the profiles.";
    };
    modules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
      description = "Modules that belong to this one target only, such as its hardware.";
    };
  };

  homeType = types.submodule {
    options =
      selection "homeManager"
      // {
        stateVersion = mkOption {
          type = types.str;
          description = "home.stateVersion of this user on this host.";
        };
      };
  };

  hostType = types.submodule ({
    name,
    config,
    ...
  }: {
    options =
      selection config.class
      // {
        class = mkOption {
          type = types.enum ["nixos" "darwin"];
          description = "Which builder assembles the host.";
        };
        system = mkOption {
          type = types.enum flakeSystems;
          description = "Platform of the host, one of the flake's `systems`.";
        };
        hostName = mkOption {
          type = types.str;
          default = name;
          description = "networking.hostName.";
        };
        stateVersion = mkOption {
          type = types.either types.str types.int;
          description = "system.stateVersion from the first install: a release string on NixOS, an integer on nix-darwin.";
        };
        home = mkOption {
          type = types.attrsOf homeType;
          default = {};
          description = "Home Manager users of the host, by user name.";
        };
      };
  });

  # Profiles first, then extra features; a feature named twice is applied once.
  namesOf = class: selected:
    lib.unique (lib.concatMap (profile: cfg.profiles.${class}.${profile}) selected.profiles ++ selected.features);

  # The key lets the module system drop a feature that reaches one system twice.
  useFeature = class: name: {
    key = "lvlv#${class}.${name}";
    imports = [features.${class}.${name}];
  };

  homeManagerFor = {
    nixos = inputs.home-manager.nixosModules.home-manager;
    darwin = inputs.home-manager.darwinModules.home-manager;
  };

  mkHost = host: let
    # Intel Macs are built from different nixpkgs and nix-darwin inputs (see systems.nix).
    stack = cfg.inputsFor host.system;
    build = {
      nixos = stack.nixpkgs.lib.nixosSystem;
      darwin = stack.nix-darwin.lib.darwinSystem;
    };
    names = namesOf host.class host;
    # The homeManager part of a host's feature reaches every user of the host.
    sharedHome = map (useFeature "homeManager") (lib.filter (name: (features.homeManager or {}) ? ${name}) names);
  in
    build.${host.class} {
      modules =
        [
          {
            nixpkgs.hostPlatform = host.system;
            networking.hostName = host.hostName;
            system.stateVersion = host.stateVersion;
          }
        ]
        ++ map (useFeature host.class) names
        ++ lib.optionals (host.home != {}) [
          homeManagerFor.${host.class}
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "homebak";
              sharedModules = sharedHome;
              users =
                lib.mapAttrs (_: home: {
                  imports = map (useFeature "homeManager") (namesOf "homeManager" home) ++ home.modules;
                  home.stateVersion = home.stateVersion;
                })
                host.home;
            };
          }
        ]
        ++ host.modules;
    };

  hostsOf = class: lib.filterAttrs (_: host: host.class == class) cfg.hosts;
in {
  options.lvlv = {
    profiles = lib.genAttrs ["nixos" "darwin" "homeManager"] (class:
      mkOption {
        type = types.attrsOf (types.listOf (featureNamed class));
        default = {};
        description = "Named lists of ${class} features.";
      });
    hosts = mkOption {
      type = types.attrsOf hostType;
      default = {};
      description = "Every machine this flake builds.";
    };
  };

  config = {
    flake = {
      nixosConfigurations = lib.mapAttrs (_: mkHost) (hostsOf "nixos");
      darwinConfigurations = lib.mapAttrs (_: mkHost) (hostsOf "darwin");
    };

    # `nix flake check` builds every host of the current platform.
    perSystem = {system, ...}: {
      checks =
        lib.mapAttrs' (name: host: {
          name = "host-${name}";
          value = config.flake."${host.class}Configurations".${name}.config.system.build.toplevel;
        })
        (lib.filterAttrs (_: host: host.system == system) cfg.hosts);
    };
  };
}
