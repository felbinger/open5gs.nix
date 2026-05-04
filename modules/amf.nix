{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.amf;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "AMF";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "amf.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        AMF configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "amf";
        })
        logger
        global
        ;

      amf = mkOption {
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
                                default = "127.0.0.5";
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
            ngap = mkOption {
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
                                default = "127.0.0.5";
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
                                default = "127.0.0.5";
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
            guami = mkOption {
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
                      amf_id = mkOption {
                        type = types.nullOr (
                          types.submodule {
                            freeformType = yaml.type;
                            options = {
                              region = mkOption {
                                type = types.int;
                                default = 2;
                              };
                              set = mkOption {
                                type = types.int;
                                default = 1;
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
            tai = mkOption {
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
                      tac = mkOption {
                        type = types.int;
                        default = 1;
                      };
                    };
                  }
                )
              );
              default = [ { } ];
            };
            plmn_support = mkOption {
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
                      s_nssai = mkOption {
                        type = types.nullOr (
                          types.submodule {
                            freeformType = yaml.type;
                            options = {
                              sst = mkOption {
                                type = types.int;
                                default = 1;
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
            security = mkOption {
              type = types.nullOr (
                types.submodule {
                  freeformType = yaml.type;
                  options = {
                    integrity_order = mkOption {
                      type = types.listOf types.str;
                      default = [
                        "NIA2"
                        "NIA1"
                        "NIA0"
                      ];
                    };
                    ciphering_order = mkOption {
                      type = types.listOf types.str;
                      default = [
                        "NEA0"
                        "NEA1"
                        "NEA2"
                      ];
                    };
                  };
                }
              );
              default = { };
            };
            network_name = mkOption {
              type = types.nullOr (
                types.submodule {
                  freeformType = yaml.type;
                  options = {
                    full = mkOption {
                      type = types.str;
                      default = "Open5GS";
                    };
                    short = mkOption {
                      type = types.str;
                      default = "Next";
                    };
                  };
                }
              );
              default = { };
            };
            amf_name = mkOption {
              type = types.str;
              default = "open5gs-amf0";
            };
            time = mkOption {
              type = types.nullOr (
                types.submodule {
                  freeformType = yaml.type;
                  options = {
                    t3502 = mkOption {
                      type = types.nullOr (
                        types.submodule {
                          freeformType = yaml.type;
                          options = {
                            value = mkOption {
                              type = types.int;
                              default = 720; # 12 minutes * 60 = 720 seconds
                            };
                          };
                        }
                      );
                    };
                    t3512 = mkOption {
                      type = types.nullOr (
                        types.submodule {
                          freeformType = yaml.type;
                          options = {
                            value = mkOption {
                              type = types.int;
                              default = 540; # 9 minutes * 60 = 540 seconds
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
