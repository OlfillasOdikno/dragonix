# Dragonix

A nix flake to manage your Ghidra extensions

## Packaged Extensions
- Ghidrathon

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


