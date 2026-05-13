{
  description = "Wisp File Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        dev-shell = import ./nix/dev-shell.nix { inherit pkgs; };
      in {

        devShells.default = dev-shell;

      });
}
