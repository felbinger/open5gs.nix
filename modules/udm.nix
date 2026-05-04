{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.udm;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "UDM";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "udm.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        UDM configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "udm";
        })
        logger
        global
        ;

      udm = mkOption {
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
                                default = "127.0.0.12";
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
            #hnet = mkOption {
            #  type = types.nullOr (
            #    types.listOf (
            #      types.submodule {
            #        freeformType = yaml.type;
            #        options = {
            #          id = mkOption {
            #            type = types.int;
            #          };
            #          schema = mkOption {
            #            type = types.int;
            #          };
            #          key = mkOption {
            #            type = types.path;
            #          };
            #        };
            #      }
            #    )
            #  );
            #  default = [ { } ]; # TODO generate default keys
            #};
          };
        };
        default = { };
      };
    };
  };
}
