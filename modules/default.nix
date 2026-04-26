{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.open5gs;
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    ;
in
{
  meta.maintainers = with lib.maintainers; [ felbinger ];

  options.services.srsran = {
    enable = mkEnableOption "Open5GS";

    package = mkPackageOption pkgs "open5gs" { };

    # TODO
  };

  config = mkIf cfg.enable {
    assertions = [
      # TODO
    ];

    systemd.services = {
      # TODO
    };
  };
}
