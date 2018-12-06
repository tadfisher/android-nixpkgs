{ mkGeneric }:

package:

let
  inherit (builtins) elemAt filter split;

  sysImgPath = elemAt (filter (x: x != [])  (split ";" package.path)) 2;

in mkGeneric {
  inherit package;
  repoUrl = "https://dl.google.com/android/repository/sys-img/${sysImgPath}";
}
