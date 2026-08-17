{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkPackageOption;
in
{
  options = {
    enable = mkEnableOption "WebUI";
    package = mkPackageOption pkgs "open5gs-webui" { } // {
      apply =
        pkg:
        pkg.overrideAttrs {
          installPhase = ''
            # remove code trying to write .env into nix store. TODO not working
            rm ./server/ensure-secret.js
            sed -i "s|require('./ensure-secret')();||" ./server/index.js
          '';
        };
    };
  };
}
