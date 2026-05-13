{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {

  buildInputs = with pkgs; [

    flutter

    cmake
    clang

    pkg-config
    gtk3
    libsysprof-capture
    pcre2
    util-linux
    libselinux
    libsepol
    libthai
    libdatrie
    xorg.libXdmcp
    lerc
    libxkbcommon
    libepoxy
    xorg.libXtst

  ];

}
