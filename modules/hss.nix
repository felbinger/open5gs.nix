{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.hss;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "HSS";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "hss.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        HSS configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "hss";
        })
        logger
        global
        ;
    };
  };

}
