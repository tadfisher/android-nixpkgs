{ lib
, writeShellScriptBin
, git
, gradle
, jq
, xml-to-json-fast
, repos
, fetchSources ? false
}:

let
  gradleOpts = "-Pnix.repos='${lib.concatStringsSep "," repos}'";
  lockTasks = "dependencies" + lib.optionalString (fetchSources) " downloadSources";

in
writeShellScriptBin "update-locks" ''
  set -eu -o pipefail

  EXTRA_OPTS=
  if [ "''${1-}" == "-s" ]; then
    EXTRA_OPTS="$EXTRA_OPTS downloadSources"
  fi

  cd "$(${git}/bin/git rev-parse --show-toplevel)/nix-android-repo"

  ${gradle}/bin/gradle ${gradleOpts} ${lockTasks} $EXTRA_OPTS --write-locks --write-verification-metadata sha256

  ${xml-to-json-fast}/bin/xml-to-json-fast gradle/verification-metadata.xml |
    ${jq}/bin/jq '[ .items[] | select(.name == "components") | .items[] |
      .attrs + { artifacts: [ .items[] | { (.attrs.name): .items[0].attrs.value } ] | add } ]' > deps.json

  rm gradle/verification-metadata.xml
''
