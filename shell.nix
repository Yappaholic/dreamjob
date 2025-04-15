{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let packages = [
    xorg.libX11
    xorg.libXi.dev
    xorg.libXinerama.dev
    xorg.libXrandr.dev
    xorg.libXcursor.dev
    wayland.dev
    alsa-lib
    libGL
    ]; in

mkShell {
  packages = packages;
  nativeBuildInputs = packages;
  LD_LIBRARY_PATH = lib.makeLibraryPath packages;
  CPATH = lib.makeIncludePath packages;
}
