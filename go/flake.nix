{
  description = "My flake based Go development environment";

  input.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

  outputs =
    inputs:
    let
      go-version = 23; # Update version when needed

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        inputs.nixpkgs.lib.genAttrs forAllSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.self.overlays.default ];
            };
          }

        );
    in

    {
      overlays.default = final: prev: {
        go = final."go_1_${toString go-version}";
      };
      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              go # The Go programming language compiler and toolchain
              gotools # Extra Go tools (e.g., godoc, goimports, etc.)
              golangci-lint # Fast Go linters aggregator (static code analysis for Go)

            ];
          };
        }
      );
    };
}
