{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.sepp;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "SEPP";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "sepp.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        SEPP configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "sepp";
        })
        logger
        global
        ;
    };
  };

}
