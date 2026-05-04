{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.sgwu;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "SGWU";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "sgwu.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        SGWU configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "sgwu";
        })
        logger
        global
        ;
    };
  };
}
