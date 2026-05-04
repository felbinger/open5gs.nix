{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.sgwc;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "SGWC";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "sgwc.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        SGWC configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "sgwc";
        })
        logger
        global
        ;
    };
  };
}
