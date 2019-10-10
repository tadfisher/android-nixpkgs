{ mkGeneric }:

package:

let
  inherit (builtins) elemAt filter split;

  sysImgPath = elemAt (filter (x: x != [])  (split ";" package.id)) 2;

in mkGeneric {
  phases = [ "unpackPhase" "installPhase" ];
  repoUrl = "https://dl.google.com/android/repository/sys-img/${sysImgPath}";
} package
