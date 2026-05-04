{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.nrf;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "NRF";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "nrf.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        NRF configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "nrf";
        })
        logger
        global
        ;

      nrf = mkOption {
        type = types.submodule {
          freeformType = yaml.type;
          options = {
            serving = mkOption {
              type = types.nullOr (
                types.listOf (
                  types.submodule {
                    freeformType = yaml.type;
                    options = {
                      plmn_id = mkOption {
                        type = types.nullOr (
                          types.submodule {
                            freeformType = yaml.type;
                            options = {
                              mcc = mkOption {
                                type = types.int;
                                default = 999;
                              };
                              mnc = mkOption {
                                type = types.int;
                                default = 70;
                              };
                            };
                          }
                        );
                        default = { };
                      };
                    };
                  }
                )
              );
              default = [ { } ];
            };
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
                                default = "127.0.0.10";
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
