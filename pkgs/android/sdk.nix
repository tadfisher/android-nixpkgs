{
  stdenv,
  lib,
  runCommand,
  linkFarm,
  makeWrapper,
  writeShellScript,
  writeText,
  packages,
}:

pkgsFun:
let
  inherit (builtins) attrValues concatStringsSep length;

  inherit (lib)
    all
    any
    assertMsg
    concatMapStringsSep
    filterAttrs
    findFirst
    groupBy
    groupBy'
    mapAttrs
    mapAttrsToList
    unique
    versionOlder
    ;

  packages' = filterAttrs (_: p: lib.isDerivation p) packages;

  pkgs = unique (pkgsFun packages');

  duplicates = filterAttrs (path: ps: (length ps) > 1) (groupBy (p: p.path) pkgs);

  duplicateMsg =
    let
      msg = path: ps: "${path}:\n" + concatMapStringsSep "\n" (p: "  ${p.name}") ps;
    in
    concatStringsSep "\n\n" (mapAttrsToList msg duplicates);

  licenses =
    let
      licenseHashes = groupBy' (sum: p: unique (sum ++ [ p.license.hash ])) [ ] (p: p.license.id) (
        builtins.attrValues packages'
      );
      licenseFiles = mapAttrs (
        id: hashes: writeText id ("\n" + (concatStringsSep "\n" hashes))
      ) licenseHashes;
    in
    linkFarm "android-licenses" (
      mapAttrsToList (id: file: {
        name = id;
        path = file;
      }) licenseFiles
    );

  installSdk = concatMapStringsSep "\n" (pkg: ''
    pkgBase="$ANDROID_SDK_ROOT/${pkg.path}"
    mkdir -p "$(dirname $pkgBase)"
    cp -as ${pkg}/ $pkgBase
    chmod +w $pkgBase
    cp "${pkg.xml}" $pkgBase/package.xml
    ${pkg.installSdk or ""}
  '') pkgs;

  cmdlineTools = findFirst (p: p.pname == "cmdline-tools") null pkgs;

  # Sanity-check the assembled SDK. cmdline-tools 23 replaced sdkmanager with a
  # shim over the 'android' CLI, which reaches the network for anything that
  # touches the package repository, so there we can only check that both entry
  # points resolve to the packaged CLI and run. Both want a writable home for
  # their analytics directory.
  smokeTest =
    if versionOlder cmdlineTools.version "23" then
      ''
        export ANDROID_SDK_HOME=$(mktemp -d)
        touch $ANDROID_SDK_HOME/repositories.cfg
        $out/bin/sdkmanager --list --verbose
      ''
    else
      ''
        export HOME=$(mktemp -d)
        $out/bin/android --version
        $out/bin/sdkmanager --version
      '';

  sdk =
    runCommand "android-sdk-env"
      {
        name = "android-sdk-env";
        buildInputs = [ licenses ] ++ pkgs;
        nativeBuildInputs = [ makeWrapper ];
        preferLocalBuild = true;
        allowSubstitutes = false;
        setupHook = writeText "setup-hook" ''
          export ANDROID_SDK_ROOT="@out@/share/android-sdk"
          # Android Studio uses this even though it is deprecated.
          export ANDROID_HOME="$ANDROID_SDK_ROOT"
        '';
        shellHook = ''
          echo Using Android SDK root: $out/share/android-sdk
          export ANDROID_SDK_ROOT="$out/share/android-sdk"
          # Android Studio uses this even though it is deprecated.
          export ANDROID_HOME="$ANDROID_SDK_ROOT"
        '';
        passthru.packages = pkgs;
      }
      ''
        export ANDROID_SDK_ROOT=$out/share/android-sdk
        mkdir -p "$ANDROID_SDK_ROOT"
        mkdir -p "$out/bin"

        ${installSdk}

        mkdir -p "$ANDROID_SDK_ROOT/licenses"
        cp -as ${licenses}/* "$ANDROID_SDK_ROOT/licenses"

        ${smokeTest}

        # Normally done in fixupPhase
        source ${stdenv.setup}
        mkdir -p "$out/nix-support"
        substituteAll "$setupHook" "$out/nix-support/setup-hook"
      '';

in
assert (
  assertMsg (duplicates == { }) ''
    The following SDK packages collide:

    ${duplicateMsg}
  ''
);

assert (
  assertMsg (all (
    p: p.pname != "tools"
  ) pkgs) "The 'tools' package is obsolete. Use 'cmdline-tools' instead."
);

assert (
  assertMsg (any (
    p: p.pname == "cmdline-tools"
  ) pkgs) "Missing 'cmdline-tools' package, which is required for a working Android SDK."
);

sdk
