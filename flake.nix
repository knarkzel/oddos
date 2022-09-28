{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-22.05";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    overlays = [
      # Zig overlay
      (final: prev: {
        zigpkgs = inputs.zig-overlay.packages.${prev.system};
      })
    ];
    # Our supported systems are the same supported systems as the Zig binaries
    systems = builtins.attrNames inputs.zig-overlay.packages;
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = import nixpkgs {inherit overlays system;};
      in rec {
        devShell = pkgs.mkShell {
          buildInputs = [pkgs.zigpkgs.default pkgs.qemu];
        };
      }
    );
}
