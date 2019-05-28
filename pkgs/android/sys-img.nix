{ mkGeneric }:

package:

let
  inherit (builtins) elemAt filter split;

  sysImgPath = elemAt (filter (x: x != [])  (split ";" package.id)) 2;

in mkGeneric (package // {
  repoUrl = "https://dl.google.com/android/repository/sys-img/${sysImgPath}";
})
