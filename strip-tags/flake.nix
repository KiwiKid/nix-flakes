{
  description = "A basic Python project - strip-tags";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.python3Packages.buildPythonPackage {
          pname = "strip-tags";
          version = "0.1.0";

          src = pkgs.fetchFromGitHub {
            owner = "simonw";
            repo = "strip-tags";
            rev = "main";
            sha256 = "sha256-Oy4xii668Y37gWJlXtF0LgU+r5seZX6l2SjlqLKzaSU=";
          };

          meta = with pkgs.lib; {
            description = "A basic Python project to strip HTML tags from strings";
            homepage = "https://github.com/simonw/strip-tags";
            license = licenses.mit;
            maintainers = [ maintainers.simonw ];
          };

          nativeBuildInputs = with pkgs.python3Packages; [
            pip
            html5lib
          ];

          propagatedBuildInputs = with pkgs.python3Packages; [
            beautifulsoup4
            click
          ];

          checkInputs = with pkgs.python3Packages; [
            pytest
          ];

          doCheck = true;
          pythonImportsCheck = ["strip_tags"];
        };

        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              self.packages.${system}.default
            ];

            shellHook = ''
              echo "strip-tags version $(${self.packages.${system}.default}/bin/strip-tags --version)"
            '';
          };
        };

        overlay = final: prev: {
          strip-tags = self.packages.${system}.default;
        };

        packages.${system}.default = self.packages.${system}.default;
      });
}
