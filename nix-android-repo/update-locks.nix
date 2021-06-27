{ lib
, writeShellScriptBin
, git
, gradle
, jq
, xml-to-json
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

  ${xml-to-json}/bin/xml-to-json -sam -t components gradle/verification-metadata.xml \
    | ${jq}/bin/jq '[
        .[] | .component |
        { group, name, version,
          artifacts: [([.artifact] | flatten | .[] | {(.name): .sha256.value})] | add
        }
      ]' > deps.json

  rm -f gradle/verification-metadata.xml
''
