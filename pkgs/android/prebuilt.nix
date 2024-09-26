{ stdenv
, lib
, autoPatchelfHook
, mkGeneric
, libedit
, bzip2
, ncurses5
, zlib
}:

{ id, ... }@package:
let
  inherit (builtins) replaceStrings;
  inherit (lib) hasPrefix recursiveUpdate;

  buildArgs = lib.optionalAttrs stdenv.isLinux
    (
      if (hasPrefix "cmake;" id || hasPrefix "skiaparser;" id) then {
        nativeBuildInputs = [ autoPatchelfHook ];
        buildInputs = [ bzip2 ncurses5 stdenv.cc.cc.lib ];
      }
      else { }
    );

in
mkGeneric buildArgs package
