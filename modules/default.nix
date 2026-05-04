{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.open5gs;
  yaml = pkgs.formats.yaml { };
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    types
    ;
  components = [
    "amf" # 5G Access and Mobility Management Function
    "ausf" # 5G Authentication Server Function
    "bsf" # 5G Binding Support Function
    # "hss" # 4G Home Subscriber Server
    # "mme" # 4G Mobility Management Entity
    "nrf" # 5G Network Repository Function
    "nssf" # 5G Network Slice Selection Function
    "pcf" # 5G Policy Control (and Charging) Function
    # "pcrf" # 4G Policy and Charging Rules Function
    "scp" # 5G Service Communication Proxy
    "sepp" # 5G Security Edge Protection Proxy
    # "sgwc" # 4G Serving Gateway Control Plane
    # "sgwu" # 4G Serving Gateway User Plane
    "smf" # 5G Session Management Function
    "udm" # 5G Unified Data Management
    "udr" # 5G Unified Data Repository
    "upf" # 5G User Plane Function
  ];
in
{
  meta.maintainers = with lib.maintainers; [ felbinger ];

  options.services.open5gs = {
    enable = mkEnableOption "Open5GS";

    package = mkPackageOption pkgs "open5gs" { };
  }
  // (builtins.listToAttrs (
    map (v: {
      name = "${v}";
      value = mkOption {
        type = types.submodule (
          import ./${v}.nix {
            inherit
              config
              lib
              yaml
              pkgs
              ;
          }
        );
        default = { };
        description = "${v} settings";
      };
    }) components
  ));

  config = mkIf cfg.enable {
    assertions = [
      # TODO
      # AMF/AUSF/BSF/NSSF/PCF/SEPP/SMF/UDR/UDM .SBI one of NRF and SCP is enabled
    ];

    users = {
      groups.open5gs = { };
      users.open5gs = {
        isSystemUser = true;
        group = "open5gs";
      };
    };

    services.mongodb = mkIf cfg.udr.enable {
      enable = true;
      package = cfg.udr.mongodbPackage;
      initialScript = pkgs.writeText "mongodb-setup.js" ''
        const db = db.getSiblingDB("open5gs");

        function ensureCollection(name) {
          const exists = db.getCollectionNames().includes(name);
          if (!exists) db.createCollection(name);
        }

        ensureCollection("sessions");
        ensureCollection("users");
        ensureCollection("subscribers");
      '';
    };

    systemd = {
      tmpfiles.settings."10-open5gs"."/var/log/open5gs"."d" = {
        user = "open5gs";
        group = "open5gs";
        mode = "0700";
      };

      services = builtins.listToAttrs (
        map (v: {
          name = "open5gs-${v}d";
          value = {
            description = "Open5GS ${v} Daemon";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              # TODO upf requires elevated privileges to create tunnel device, maybe with recursive update for this single service?
              #User = "open5gs";
              #Group = "open5gs";
              ExecStart = "${lib.getExe' cfg.package "open5gs-${v}d"} -c ${cfg."${v}".configFile}";
              ExecReload = "${lib.getExe' pkgs.busybox "kill"} -HUP $MAINPID";
              Restart = "always";
              RestartSec = 2;
              RestartPreventExitStatus = 1;
            };
          };
        }) (builtins.filter (v: cfg.${v}.enable) components)
      );
    };
  };
}
