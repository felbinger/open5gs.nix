{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.pcrf;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "PCRF";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "pcrf.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        PCRF configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "pcrf";
        })
        logger
        global
        ;

      db_uri = mkOption {
        type = types.str;
        default = "mongodb://localhost/open5gs";
      };
    };
  };

}
