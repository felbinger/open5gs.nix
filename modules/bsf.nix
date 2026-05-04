{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.open5gs.bsf;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "BSF";

    configFile = mkOption {
      type = types.path;
      visible = false;
      default = yaml.generate "bsf.yaml" (lib.filterAttrsRecursive (_k: v: v != null) cfg.settings);
      description = ''
        BSF configuration file
      '';
    };

    settings = {
      inherit
        (import ./common.nix {
          inherit lib yaml;
          component = "bsf";
        })
        logger
        global
        ;
    };
  };

}
