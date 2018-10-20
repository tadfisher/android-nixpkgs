{ pkgs ? import <nixpkgs> {} }:

{
  androidPackages = pkgs.callPackage ./android-packages {};
}
