{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    search = {
      url = "github:NuschtOS/search";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      search,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      defaultSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      eachDefaultSystem = lib.genAttrs defaultSystems;
    in
    {
      nixosModules = rec {
        open5gs = ./modules;
        default = open5gs;
      };

      packages = eachDefaultSystem (
        system:
        let
          pkgs = (import nixpkgs) { inherit system; };
        in
        {
          default = search.packages.${system}.mkSearch {
            modules = [
              self.nixosModules.default
              {
                _module.args = {
                  inherit pkgs;
                };
              }
            ];
            title = "Module Search of rat.nix/Open5GS.nix";
            baseHref = "/open5gs.nix/";
            urlPrefix = "https://github.com/rat-nix/open5gs.nix/blob/main/";
          };
        }
      );

      formatter = eachDefaultSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
      checks = eachDefaultSystem (system: import ./checks { inherit self inputs system; });
      apps = eachDefaultSystem (
        system:
        import ./checks {
          inherit self inputs system;
          interactive = true;
        }
      );
    };
}
