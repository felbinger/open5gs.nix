{
  lib,
  yaml,
  component,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  logger = mkOption {
    type = types.submodule {
      freeformType = yaml.type;
      options = {
        file = mkOption {
          type = types.submodule {
            freeformType = yaml.type;
            options = {
              path = mkOption {
                type = types.str;
                default = "/var/log/open5gs/${component}.log";
              };
            };
          };
          default = { };
        };
        level = mkOption {
          type =
            with types;
            nullOr (enum [
              "fatal"
              "error"
              "warn"
              "info" # default
              "debug"
              "trace"
            ]);
          default = null;
        };
      };
    };
    default = { };
  };

  global = mkOption {
    type = types.nullOr (
      types.submodule {
        freeformType = yaml.type;
        options = {
          max = mkOption {
            type = types.nullOr (
              types.submodule {
                freeformType = yaml.type;
                options = {
                  ue = mkOption {
                    type = types.int;
                    description = "The number of UE can be increased depending on memory size.";
                  };
                  peer = mkOption {
                    type = types.int;
                  };
                };
              }
            );
          };
        };
      }
    );
  };
}
