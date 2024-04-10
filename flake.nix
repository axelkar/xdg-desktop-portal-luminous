{
  description = "xdg-desktop-portal-luminous devel";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      # System types to support.
      targetSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs targetSystems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.stdenv.mkDerivation rec {
            pname = "xdg-desktop-portal-luminous";
            version = "0.1.4";

            src = ./.;

            nativeBuildInputs = with pkgs; [
              clang
              cargo
              rustc
              rustPlatform.cargoSetupHook
              rustPlatform.bindgenHook

              meson
              ninja
              pkg-config
              wayland-scanner
            ];

            cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
              inherit src;
              hash = "sha256-6zkGl67LwiflnbbEsX25P7gRvW9Tt99wyyGDhn2UOYs=";
            };

            buildInputs = with pkgs; [
              pipewire.dev
              #wayland.dev # is this needed?
              libxkbcommon
              #glib.dev # is this needed?
              pango.dev
              cairo.dev
            ];

            meta = with nixpkgs.lib; {
              description = "An alternative to xdg-desktop-portal-wlr for wlroots compositors";
              homepage = "https://github.com/";
            };
          };
        }
      );

      overlays.default = final: prev: {
        inherit (self.packages.${prev.system}) xdg-desktop-portal-luminous;
      };

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "xdg-desktop-portal-luminous-devel";
            nativeBuildInputs = with pkgs; [
              # Compilers
              clang
              cargo
              rustc
              rustPlatform.bindgenHook

              # Libs
              pipewire
              wayland
              libxkbcommon
              stdenv
              glib
              pango
              cairo

              # Tools
              meson
              ninja
              gdb
              pkg-config
              rust-analyzer
              rustfmt
              strace
              valgrind
              wayland-scanner
            ];
          };
        }
      );
    };
}
