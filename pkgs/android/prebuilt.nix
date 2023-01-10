{ stdenv
, lib
, autoPatchelfHook
, mkGeneric
, libedit
, ncurses5
, zlib
}:

{ id, ... }@package:
let
  inherit (builtins) replaceStrings;
  inherit (lib) hasPrefix recursiveUpdate;

  buildArgs = lib.optionalAttrs stdenv.isLinux (
    if (hasPrefix "cmake;" id || hasPrefix "skiaparser;" id) then {
      nativeBuildInputs = [ autoPatchelfHook ];
      buildInputs = [ ncurses5 stdenv.cc.cc.lib ];
    }
    else { }
  );

in
mkGeneric buildArgs package
