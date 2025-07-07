{
  description = "Zig PortAudio wrappers.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zig

            pkg-config

            alsa-lib # for the ALSA backend
            jack2    # for the JACK backend
            linuxHeaders # OSS
          ];
        };
      });
}