# Dragonix

A nix flake to manage your Ghidra extensions

## Packaged Extensions
- [Ghidrathon](https://github.com/mandiant/Ghidrathon)
- [Delinker](https://github.com/boricj/ghidra-delinker-extension)

## Usage with NixOS system flake

```nix
{
    intpus = {
        # ...
        dragonix = {
            url = "github:OlfillasOdikno/dragonix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {nixpkgs, dragonix, ...}: 
    {
        nixosConfigurations.defalt = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ({...}: {
                    nixpkgs.overlays = [ dragonix.overlays.default ];
                    environment.systemPackages = [ 
                        (ghidra.withExtensions [ ghidra.extensions.ghidrathon ])
                    ];
                })
            ];
        }
    }
}

```


