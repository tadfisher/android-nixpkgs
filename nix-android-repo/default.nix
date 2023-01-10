{ lib
, final
, prev ? final
}:

let
  inherit (final) callPackage runCommand;

  repos = [
    "https://repo1.maven.org/maven2"
    "https://dl.google.com/dl/android/maven2"
    "https://plugins.gradle.org/m2"
  ];

  buildMavenRepo = callPackage ./maven-repo.nix { };

in
rec {
  gradle-properties = runCommand "gradle.properties"
    {
      mavenRepo = "file://${maven-repo}";
    } ''
    substituteAll ${./gradle.properties.in} $out
  '';

  nix-android-repo = callPackage ./nix-android-repo.nix {
    inherit maven-repo;
  };

  maven-repo = buildMavenRepo {
    inherit repos;
    deps = builtins.fromJSON (builtins.readFile ./deps.json);
    fetchSources = true;
  };

  update-locks = callPackage ./update-locks.nix {
    inherit (final.haskellPackages) xml-to-json-fast;
    inherit repos;
    fetchSources = true;
  };
}
