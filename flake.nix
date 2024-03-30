{
  description = "Manage Ghidra extensions using nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      overlay =
        (final: prev: {
          ghidra = prev.ghidra.overrideAttrs (old: {
            passthru = {
              extensions = {
                ghidrathon = final.callPackage ./extensions/ghidrathon.nix { };
              };
              withExtensions = extensions: final.callPackage ./wrapper.nix {
                inherit (final) ghidra;
                inherit extensions;
              };
            };
          });

          python3 = prev.python3 // {
            pkgs = prev.python3.pkgs.overrideScope (self: prev: {
              jep = final.callPackage ./packages/jep.nix { };
            });
          };
          python3Packages = final.python3.pkgs;
        })
      ;
      forAllSystems = f:
        lib.genAttrs lib.systems.flakeExposed (system:
          f (import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ overlay ];
          }));
    in
    {
      overlays.default = overlay;
      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
      packages = forAllSystems (pkgs: {
        inherit (pkgs) ghidra;
        allExtensions = pkgs.ghidra.withExtensions (with pkgs.ghidra.extensions; [
          ghidrathon
        ]);
      });
    };
}
