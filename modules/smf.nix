{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.smf;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "SMF";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "smf.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        SMF configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "smf";
        })
        logger
        global
        ;

      smf = mkOption {
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
                                default = "127.0.0.4";
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
                                default = "127.0.0.4";
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
                            upf = mkOption {
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
                  };
                }
              );
              default = { };
            };
            gtpc = mkOption {
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
                                default = "127.0.0.4";
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
                                default = "127.0.0.4";
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
                                default = "127.0.0.4";
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
            dns = mkOption {
              type = types.nullOr (types.listOf (types.str));
              default = [
                "8.8.8.8"
                "8.4.4.8"
                "2001:4860:4860::8888"
                "2001:4860:4860::8844"
              ];
            };
            mtu = mkOption {
              type = types.int;
              default = 1400;
            };
            #freeDiameter = mkDefault {
            #  type = types.path;
            #};
            # TODO
          };
        };
        default = { };
      };
    };
  };

}
