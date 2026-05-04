{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.upf;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "UPF";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "upf.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        UPF configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "upf";
        })
        logger
        global
        ;

      upf = mkOption {
        type = types.submodule {
          freeformType = yaml.type;
          options = {
            pfcp = mkOption {
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
                                default = "127.0.0.7";
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
                            smf = mkOption {
                              type = types.nullOr (
                                types.listOf (
                                  types.submodule {
                                    freeformType = yaml.type;
                                    options = {
                                      address = mkOption {
                                        type = types.str;
                                        default = "127.0.0.4";
                                      };
                                    };
                                  }
                                )
                              );
                            };
                          };
                        }
                      );
                    };
                  };
                }
              );
              default = { };
            };
            gtpu = mkOption {
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
                                default = "127.0.0.7";
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

            session = mkOption {
              type = types.nullOr (
                types.listOf (
                  types.submodule {
                    freeformType = yaml.type;
                    options = {
                      subnet = mkOption {
                        type = types.str;
                        default = "10.45.0.0/16";
                      };
                      gateway = mkOption {
                        type = types.str;
                        default = "10.45.0.1";
                      };
                    };
                  }
                )
              );
              default = [
                {
                  subnet = "10.45.0.0/16";
                  gateway = "10.45.0.1";
                }
                {
                  subnet = "2001:db8:cafe::/48";
                  gateway = "2001:db8:cafe::1";
                }
              ];
            };

            metrics = mkOption {
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
                                default = "127.0.0.7";
                              };
                              port = mkOption {
                                type = types.int;
                                default = 9090;
                              };
                            };
                          }
                        )
                      );
                    };
                  };
                }
              );
            };
          };
        };
        default = { };
      };
    };
  };

}
