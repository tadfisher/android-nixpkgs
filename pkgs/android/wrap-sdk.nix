{ buildEnv
, makeSetupHook
, writeText
# composeSdk dependencies
, lib
, linkFarm
, makeWrapper
, packages
, runCommand
, stdenv
}:

pkgsFun:

let
  composeSdk = import ./sdk.nix {
    inherit lib linkFarm makeWrapper packages runCommand stdenv writeText;
  };
  sdk = composeSdk pkgsFun;

  shellInit = ''
    export ANDROID_SDK_ROOT="${sdk}/share/android-sdk"
    export ANDROID_SDK_HOME="$(mktemp -d)"
    touch "$ANDROID_SDK_HOME/repositories.cfg"
  '';

  setupScript = writeText "android-sdk-setup-hook.sh" ''
    addAndroidSdkVars() {
      ${shellInit}
    }

    if [ -z "''${dontSetAndroidSdkRoot:-}" ]; then
      addEnvHooks "$hostOffset" addAndroidSdkVars
    fi
  '';
in
runCommand "android-sdk-env" {
  setupHook = makeSetupHook { } setupScript;
  shellHook = shellInit;
} ''
  mkdir -p $out
''
