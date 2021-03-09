{ stdenv
, lib
, autoPatchelfHook
, mkGeneric
, libedit
, ncurses5
, python27
, zlib
}:

{ id, ... }@package:
let
  inherit (builtins) replaceStrings;
  inherit (lib) hasPrefix recursiveUpdate;

  buildArgs = lib.optionalAttrs stdenv.isLinux (
    if (hasPrefix "cmake;" id || hasPrefix "skiaparser;" id) then {
      nativeBuildInputs = [ autoPatchelfHook ];
      buildInputs = [ stdenv.cc.cc.lib ];
    }

    else if (hasPrefix "lldb" id) then rec {
      nativeBuildInputs = [ autoPatchelfHook ];

      buildInputs = [
        libedit
        ncurses5
        python27
        stdenv.cc.cc.lib
        zlib
      ];

      dontAutoPatchelf = true;

      runtimeDependencies = [ zlib ];

      postUnpack = ''
        rm -r "$out/lib/{libedit.so.*,libpython2.7.so.*,libtinfo.so.*,python2.7}
        ln -s ${zlib}/lib/libz.so.1 $out/lib/libz.so.1

        addAutoPatchelfSearchPath "$out/lib"
        addAutoPatchelfSearchPath "$out/bin"
        autoPatchelf --no-recurse "$out/lib"
        autoPatchelf --no-recurse "$out/bin"
      '';
    }

    else { }
  );

in
mkGeneric buildArgs package
