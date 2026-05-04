{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.scp;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "SCP";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "scp.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        SCP configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "scp";
        })
        logger
        global
        ;

      scp = mkOption {
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
                                default = "127.0.0.200";
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
    };
  };
}
