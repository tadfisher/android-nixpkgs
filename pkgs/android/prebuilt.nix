{ stdenv, autoPatchelfHook, mkGeneric
, libedit, ncurses5, python27, zlib  }:

package:

let
  inherit (builtins) replaceStrings;
  inherit (stdenv.lib) hasPrefix recursiveUpdate;

  buildArgs =
    if (hasPrefix "cmake;" package.id) then {
      buildInputs = [ stdenv.cc.cc.lib ];
    }

    else if (hasPrefix "lldb" package.id) then rec {
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
          rm -r $packageBase/lib/{libedit.so.*,libpython2.7.so.*,libtinfo.so.*,python2.7}
          ln -s ${zlib}/lib/libz.so.1 $packageBase/lib/libz.so.1

          addAutoPatchelfSearchPath "$packageBase/lib"
          addAutoPatchelfSearchPath "$packageBase/bin"
          autoPatchelf --no-recurse "$packageBase/lib"
          autoPatchelf --no-recurse "$packageBase/bin"
      '';
    }

    else {};

in mkGeneric ({ nativeBuildInputs = [ autoPatchelfHook ]; } // buildArgs) package
