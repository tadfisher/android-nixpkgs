{ stdenv, stdenv_32bit, fetchurl, unzip, packageXml }:

{ id
, pname
, version
, sources
, displayName
, repoUrl ? https://dl.google.com/android/repository
, support32bit ? false
, ...
} @ package:

let
  inherit (builtins) attrNames concatStringsSep filter hasAttr head listToAttrs replaceStrings;
  inherit (stdenv.lib) hasPrefix findFirst flatten groupBy mapAttrs nameValuePair optionalString;

  name = concatStringsSep "-" (filter (s: s != "") [package.pname package.version]);

  src =
    let
      # Keys by which to search the package's "sources" set for the host platform.
      hostOsKeys = with stdenv.hostPlatform; [
        system
        parsed.kernel.name
        parsed.cpu.name
        "all"
      ];

      hostSrc =
        let key = findFirst
          (k: hasAttr k package.sources)
          (throw "Unsupported system: ${stdenv.hostPlatform.system}")
          hostOsKeys;
        in package.sources.${key};

    in fetchurl {
      url = "${repoUrl}/${hostSrc.url}";
      inherit (hostSrc) sha1;
    };

  platforms = flatten (map (name:
    if (hasAttr name stdenv.lib.platforms) then stdenv.lib.platforms.${name} else name
  ) (attrNames package.sources));

  outdir = replaceStrings [";"] ["/"] package.id;

in (if support32bit then stdenv_32bit else stdenv).mkDerivation ({
  inherit name src;

  nativeBuildInputs = [ unzip ] ++ (package.nativeBuildInputs or []);

  installPhase = ''
    mkdir -p $out/${outdir}
    cp -r * $out/${outdir}/
    cp ${packageXml}/${package.pname}.xml $out/${outdir}/package.xml
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = package.displayName;
    homepage = https://developer.android.com/studio/;
    license = licenses.asl20;
    maintainers = with maintainers; [ tadfisher ];
    inherit platforms;
  } // (package.meta or {});
} // removeAttrs package [ "displayName" "sources" "support32bit" "repoUrl" "nativeBuildInputs" "meta" ])
