{ stdenv
, lib
, autoPatchelfHook
, mkGeneric
, libedit
, ncurses5
, python27
, zlib
}:

package:
let
  inherit (builtins) replaceStrings;
  inherit (lib) hasPrefix recursiveUpdate;

  buildArgs =
    if (
      hasPrefix "cmake;" package.id ||
      hasPrefix "skiaparser;" package.id
    ) then {
      buildInputs = [ stdenv.cc.cc.lib ];
    }

    else if (hasPrefix "lldb" package.id) then rec {
      buildInputs = lib.optionals stdenv.isLinux [
        libedit
        ncurses5
        python27
        stdenv.cc.cc.lib
        zlib
      ];

      dontAutoPatchelf = true;

      runtimeDependencies = lib.optionals stdenv.isLinux [ zlib ];

      postUnpack = lib.optionalString stdenv.isLinux ''
        rm -r "$out/lib/{libedit.so.*,libpython2.7.so.*,libtinfo.so.*,python2.7}
        ln -s ${zlib}/lib/libz.so.1 $out/lib/libz.so.1

        addAutoPatchelfSearchPath "$out/lib"
        addAutoPatchelfSearchPath "$out/bin"
        autoPatchelf --no-recurse "$out/lib"
        autoPatchelf --no-recurse "$out/bin"
      '';
    }

    else { };

in
mkGeneric ({ nativeBuildInputs = [ autoPatchelfHook ]; } // buildArgs) package
