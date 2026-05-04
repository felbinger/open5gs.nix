{
  config,
  pkgs,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.udr;
  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    types
    ;
in
{
  options = {
    enable = mkEnableOption "UDR";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "udr.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        UDR configuration file
      '';
    };

    mongodbPackage = mkPackageOption pkgs "mongodb-ce" { };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "udr";
        })
        logger
        global
        ;

      udr = mkOption {
        type = types.submodule {
          freeformType = yaml.type;
          options = {
            sbi = mkOption {
              type = types.nullOr (
                types.submodule {
                  freeformType = yaml.type;
                  options = {
                    server = mkOption {
                      type = types.nullOr (
                        types.listOf (
                          types.submodule {
                            freeformType = yaml.type;
                            options = {
                              address = mkOption {
                                type = types.str;
                                default = "127.0.0.20";
                              };
                              port = mkOption {
                                type = types.int;
                                default = 7777;
                              };
                            };
                          }
                        )
                      );
                      default = [ { } ];
                    };
                    client = mkOption {
                      type = types.nullOr (
                        types.submodule {
                          freeformType = yaml.type;
                          options = {
                            nrf = mkOption {
                              type = types.nullOr (
                                types.listOf (
                                  types.submodule {
                                    freeformType = yaml.type;
                                    options = {
                                      uri = mkOption {
                                        type = types.str;
                                        default = "http://127.0.0.10:7777";
                                      };
                                    };
                                  }
                                )
                              );
                            };
                            scp = mkOption {
                              type = types.nullOr (
                                types.listOf (
                                  types.submodule {
                                    freeformType = yaml.type;
                                    options = {
                                      uri = mkOption {
                                        type = types.str;
                                        default = "http://127.0.0.200:7777";
                                      };
                                    };
                                  }
                                )
                              );
                              default = [ { } ];
                            };
                          };
                        }
                      );
                      default = { };
                    };
                  };
                }
              );
              default = { };
            };
          };
        };
        default = { };
      };

      db_uri = mkOption {
        type = types.str;
        default = "mongodb://localhost/open5gs";
      };
    };
  };
}
