{ stdenv, autoPatchelfHook, mkGeneric
, libedit, ncurses5, python27, zlib  }:

package:

let
  inherit (builtins) replaceStrings;
  inherit (stdenv.lib) hasPrefix recursiveUpdate;

  singleRootUnzip = "unzip $curSrc -d src";

  buildArgs =
    if (hasPrefix "cmake" package.path) then rec {
      name = "android-prebuilt-cmake-${package.revision}";
      unpackCmd = singleRootUnzip;
      buildInputs = [ stdenv.cc.cc.lib ];
    }

    else if (hasPrefix "lldb" package.path) then
      let
        outdir = replaceStrings [";"] ["/"] package.path;
      in rec {
        name = "android-prebuilt-lldb-${package.revision}";

        unpackCmd = singleRootUnzip;

        setSourceRoot = ''
          local files=( src/* )
          if [ ''${#files[@]} -eq 1 ]; then
            sourceRoot=''${files[0]}
          else
            sourceRoot=src
          fi
        '';

        buildInputs = [
          libedit
          ncurses5
          python27
          stdenv.cc.cc.lib
          zlib
        ];

        runtimeDependencies = [ zlib ];

        installPhase = ''
          mkdir -p $out/${outdir}
          cp -r * $out/${outdir}
          rm -r $out/${outdir}/lib/{libedit.so.*,libpython2.7.so.*,libtinfo.so.*,python2.7}
          ln -s ${zlib}/lib/libz.so.1 $out/${outdir}/lib/libz.so.1
          '';
      }

    else {};

in mkGeneric (package
  // { nativeBuildInputs = [ autoPatchelfHook ]; }
  // buildArgs)
