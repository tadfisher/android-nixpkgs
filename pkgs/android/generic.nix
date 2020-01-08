{ stdenv, fetchandroid, writeText, unzip }:

{ repoUrl ? "https://dl.google.com/android/repository", ... } @ args:

package:

let
  inherit (builtins) attrNames concatStringsSep filter hasAttr head listToAttrs replaceStrings;
  inherit (stdenv.lib) hasPrefix findFirst flatten groupBy mapAttrs nameValuePair optionalString;

  platforms = flatten (map (name:
    if (hasAttr name stdenv.lib.platforms) then stdenv.lib.platforms.${name} else name
  ) (attrNames package.sources));

  outdir = replaceStrings [";"] ["/"] package.id;

  packageXml = writeText "${package.pname}-${package.version}-package-xml" package.xml;

in stdenv.mkDerivation ({

  inherit (package) pname version;

  nativeBuildInputs = [ unzip ] ++ (args.nativeBuildInputs or []);

  src = fetchandroid {
    inherit (package) sources;
    inherit repoUrl;
  };

  installPhase = ''
    packageBase="$out/${outdir}"
    mkdir -p "$packageBase"
    cp -r --reflink=auto * "$packageBase"
    ln -s ${packageXml} "$packageBase/package.xml"
    runHook postInstall
  '';

  passthru = {
    license = package.license;
  } // (args.passthru or {});

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = package.displayName;
    homepage = https://developer.android.com/studio/;
    license = licenses.asl20;
    maintainers = with maintainers; [ tadfisher ];
    inherit platforms;
  } // (args.meta or {});
} // removeAttrs args [ "nativeBuildInputs" "passthru" "meta" ])
