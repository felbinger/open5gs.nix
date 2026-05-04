{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.mme;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "MME";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "mme.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        MME configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "mme";
        })
        logger
        global
        ;
    };
  };

}
