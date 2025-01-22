{ lib
, writeShellScriptBin
, git
, gradle2nix
, gradle
, jdk
}:

writeShellScriptBin "update-locks" ''
  set -eu -o pipefail

  cd "$(${git}/bin/git rev-parse --show-toplevel)/nix-android-repo"

  ${lib.getExe gradle2nix} \
    --artifacts=sources \
    --gradle-home=${gradle}/lib/gradle \
    --gradle-jdk=${jdk.home} \
    -- --write-locks
''
