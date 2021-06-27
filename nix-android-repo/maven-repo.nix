{ lib
, stdenv
, fetchurl
, symlinkJoin
, writeTextDir
}:

{ name ? "maven-deps"
, repos ? [ ]
, deps ? [ ]
, extraPaths ? [ ]
, pinnedDeps ? { }
, fetchSources ? false
}:

with lib;

let
  mavenize = sep: replaceStrings [ "." ] [ sep ];

  fetch =
    { group
    , name
    , version
    , file
    , sha256
    }:
    let
      repos' =
        pinnedDeps."${group}:${name}" or
          pinnedDeps."${group}:${name}:${version}" or
            repos;
    in
    fetchurl {
      name = file;
      urls = map (repo: "${repo}/${mavenize "/" group}/${name}/${version}/${file}") repos';
      inherit sha256;
      curlOpts = [ "--retry 0" ];
      meta.platforms = platforms.all;
    };

  fetchDependency =
    { group
    , name
    , version
    , artifacts
    }:
    let
      fetchArtifact = file: sha256:
        fetch { inherit group name version file sha256; };

      # Each artifact uses the filename in the Gradle cache, which doesn't
      # correspond to the filename in the Maven repo. The mapping of name to URL
      # is provided by Gradle module metadata, so we fetch that first. See
      # https://github.com/gradle/gradle/blob/master/subprojects/docs/src/docs/design/gradle-module-metadata-latest-specification.md
      # for the file format.
      isModule = hasSuffix ".module";
      moduleArtifacts = filterAttrs (file: _: isModule file) artifacts;
      otherArtifacts = filterAttrs (file: _: !isModule file) artifacts;

      modules = mapAttrsToList fetchArtifact moduleArtifacts;
      modules' = map
        (module: builtins.fromJSON (builtins.readFile module))
        modules;
      variants = flatten (map (module: module.variants or [ ]) modules');

      replacements = listToAttrs (flatten
        (map
          (variant:
            let
              files = flatten (map (v: v.files or [ ]) variants);
            in
            map ({ name, url, ... }: nameValuePair name url) files
          )
          variants)
      );

      replaced =
        let
          artifacts = mapAttrs'
            (file: sha256:
              nameValuePair (replacements.${file} or file) sha256
            )
            otherArtifacts;
        in
        mapAttrsToList fetchArtifact artifacts;

      sources = if !fetchSources then [ ] else
      let
        sourcesVariants = filter (v: v.name == "sourcesElements") variants;
        files = flatten (map (v: v.files) sourcesVariants);
        # artifacts = map ({ url, sha256, ... }: nameValuePair url sha256) files;
      in
      map ({ url, sha256, ... }: fetchArtifact url sha256) files;

    in
    if moduleArtifacts == { }
    then mapAttrsToList fetchArtifact artifacts
    else modules ++ replaced ++ sources;


  mkDep =
    { group
    , name
    , version
    , artifacts
    }@dep:
    stdenv.mkDerivation {
      pname = "${mavenize "-" group}-${name}";
      inherit version;

      srcs = fetchDependency dep;

      sourceRoot = ".";

      phases = "installPhase";

      enableParallelBuilding = true;

      installPhase = ''
        dest=$out/${mavenize "/" group}/${name}/${version}
        mkdir -p $dest
        for src in $srcs; do
          ln -s $src $dest/$(stripHash $src)
        done
      '';

      passthru.maven = {
        inherit group name version;
      };
    };

  mkMetadata = deps:
    let
      modules = groupBy'
        (meta: { group, name, version, ... }:
          let
            isNewer = versionOlder meta.latest version;
            isNewerRelease = versionOlder meta.release version;
          in
          {
            groupId = group;
            artifactId = name;
            latest = if isNewer then version else meta.latest;
            release = if isNewerRelease then version else meta.release;
            versions = meta.versions ++ [ version ];
          }
        )
        {
          latest = "";
          release = "";
          versions = [ ];
        }
        ({ group, name, ... }: "${mavenize "/" group}/${name}/maven-metadata.xml")
        deps;
    in
    attrValues (mapAttrs
      (path: { groupId, artifactId, latest, release, versions }:
        let
          versions' = sort versionOlder (unique versions);
        in
        writeTextDir path ''
          <?xml version="1.0" encoding="UTF-8"?>
          <metadata modelVersion="1.1">
            <groupId>${groupId}</groupId>
            <artifactId>${artifactId}</artifactId>
            <versioning>
              ${optionalString (latest != "") "<latest>${latest}</latest>"}
              ${optionalString (release != "") "<release>${release}</release>"}
              <versions>
                ${concatMapStringsSep "\n    " (v: "<version>${v}</version>") versions'}
              </versions>
            </versioning>
          </metadata>
        ''
      )
      modules);

  mkGradleRedirectionPoms = deps:
    let
      depsMissingPoms = filter
        ({ artifacts, ... }@dep:
          any (f: hasSuffix ".module" f) (attrNames artifacts) &&
          !(any (f: hasSuffix ".pom" f) (attrNames artifacts))
        )
        deps;
    in
    map
      ({ group, name, version, ... }:
        writeTextDir "${mavenize "/" group}/${name}/${version}/${name}-${version}.pom" ''
          <project xmlns="http://maven.apache.org/POM/4.0.0"
                   xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                   http://maven.apache.org/xsd/maven-4.0.0.xsd"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <!-- This module was also published with a richer model, Gradle metadata,  -->
            <!-- which should be used instead. Do not delete the following line which  -->
            <!-- is to indicate to Gradle or any Gradle module metadata file consumer  -->
            <!-- that they should prefer consuming it instead. -->
            <!-- do_not_remove: published-with-gradle-metadata -->
            <modelVersion>4.0.0</modelVersion>
            <groupId>${group}</groupId>
            <artifactId>${name}</artifactId>
            <version>${version}</version>
          </project>
        ''
      )
      depsMissingPoms;

in
symlinkJoin {
  inherit name;
  paths = map mkDep deps ++ mkMetadata deps ++ mkGradleRedirectionPoms deps ++ extraPaths;
  preferLocalBuild = false;
  allowSubstitutes = true;
}
