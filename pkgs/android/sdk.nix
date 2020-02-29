{ stdenv, lib, runCommand, jdk8, linkFarm, makeWrapper, writeText, packages }:

pkgsFun:

let
  inherit (builtins) attrValues concatStringsSep length;

  inherit (lib) any assertMsg concatMapStringsSep filterAttrs groupBy groupBy'
    mapAttrs mapAttrsToList unique;

  pkgs = pkgsFun packages;

  duplicates = filterAttrs (path: ps: (length ps) > 1) (groupBy (p: p.path) pkgs);

  duplicateMsg =
    let msg = path: ps: "${path}:\n" + concatMapStringsSep "\n" (p: "  ${p.name}") ps;
    in concatStringsSep "\n\n" (mapAttrsToList msg duplicates);

  licenses =
    let
      licenseHashes = groupBy' (sum: p: unique (sum ++ [p.license.hash])) [] (p: p.license.id) pkgs;
      licenseFiles = mapAttrs (id: hashes: writeText id ("\n" + (concatStringsSep "\n" hashes))) licenseHashes;
    in
      linkFarm "android-licenses" (mapAttrsToList (id: file: { name = id; path = file; }) licenseFiles);

  installSdk = concatMapStringsSep "\n" (pkg: ''
    pkgBase="$ANDROID_HOME/${pkg.path}"
    mkdir -p "$(dirname $pkgBase)"
    cp -as ${pkg}/ $pkgBase
    chmod +w $pkgBase
    cp "${pkg.xml}" $pkgBase/package.xml
    ${pkg.installSdk or ""}
  '') pkgs;

in

assert (assertMsg (duplicates == {})
  ''
    The following SDK packages collide:

    ${duplicateMsg}
  ''
);

assert (assertMsg (any (p: p.pname == "tools") pkgs)
  "Missing 'tools' package, which is required for a working Android SDK.");

runCommand "android-sdk-env" {
  name = "android-sdk-env";
  buildInputs = [ licenses ] ++ pkgs;
  nativeBuildInputs = [ makeWrapper ];
  preferLocalBuild = true;
  allowSubstitutes = false;
} ''
  ANDROID_HOME="$out/share/android-sdk"
  mkdir -p "$ANDROID_HOME"
  mkdir -p "$out/bin"

  ${installSdk}

  mkdir -p "$ANDROID_HOME/licenses"
  cp -as "${licenses}/" "$ANDROID_HOME/licenses"

  export ANDROID_SDK_HOME=$(mktemp -d)
  touch $ANDROID_SDK_HOME/repositories.cfg
  $out/bin/sdkmanager --list --verbose
''
