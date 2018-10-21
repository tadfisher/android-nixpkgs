{ stdenv, fetchurl, unzip }:

{ package
, repoUrl ? https://dl.google.com/android/repository
, support32bit ? false
, ...
} @ args:

let
  inherit (builtins) attrNames concatStringsSep filter hasAttr head listToAttrs replaceStrings;
  inherit (stdenv.lib) hasPrefix findFirst flatten groupBy mapAttrs nameValuePair optionalString;

  pname = args.pname or (replaceStrings [";" "."] ["-" "-"] package.path);
  version = args.version or package.revision;
  name = args.name or (concatStringsSep "-" (filter (s: s != "") [pname version]));

  src =
    let
      # Keys by which to search the package's "sources" set for the host platform.
      hostOsKeys = {
        i686-linux = [ "linux-32" "linux" ];
        x86_64-linux = [ "linux-64" "linux" ];
        i686-darwin = [ "macosx-32" "macosx" ];
        x86_64-darwin = [ "macosx-64" "macosx" ];
      }.${stdenv.hostPlatform.system} or [];

      hostSrc =
        if hasAttr "sources" package then
          let key = findFirst
            (k: hasAttr k package.sources)
            (throw "Unsupported system: ${stdenv.hostPlatform.system}")
            hostOsKeys;
          in package.sources.${key}
        else package.source;

    in fetchurl {
      url = "${repoUrl}/${hostSrc.path}";
      inherit (hostSrc) sha1;
    };

  platforms =
    with stdenv.lib.platforms; let
      toPlatform = os: {
        "linux" = [ linux ];
        "linux-32" = [ "i686-linux" ];
        "linux-64" = [ "x86_64-linux" ];
        "macosx" = [ darwin ];
        "macosx-32" = [ "i686-darwin" ];
        "macosx-64" = [ "x86_64-darwin" ];
      }.${os} or [];
    in
      if hasAttr "sources" package
      then flatten (map toPlatform (attrNames package.sources))
      else linux ++ darwin;

  outdir = replaceStrings [";"] ["/"] package.path;

in

stdenv.mkDerivation ({
  inherit pname version name src;

  nativeBuildInputs = [ unzip ] ++ (args.nativeBuildInputs or []);

  installPhase = ''
    mkdir -p $out/${outdir}
    cp -r * $out/${outdir}/
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = package.displayName;
    homepage = https://developer.android.com/studio/;
    license = licenses.asl20;
    maintainers = with maintainers; [ tadfisher ];
    inherit platforms;
  } // (args.meta or {});
} // removeAttrs args [ "package" "support32bit" "repoUrl" "nativeBuildInputs" "meta" ])
