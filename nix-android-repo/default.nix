{ lib
, devshellPkgs
, pkgs
}:

let
  inherit (pkgs) callPackage jdk runCommand;

  repos = [
    "https://repo1.maven.org/maven2"
    "https://dl.google.com/dl/android/maven2"
    "https://plugins.gradle.org/m2"
  ];

  buildMavenRepo = callPackage ./maven-repo.nix { };

  gradle = pkgs.gradle.override {
    java = jdk;
    javaToolchains = [ jdk ];
  };

in
rec {
  devshell = callPackage ./devshell.nix {
    inherit devshellPkgs gradle gradle-properties jdk update-locks;
  };

  gradle-properties = runCommand "gradle.properties"
    {
      mavenRepo = "file://${maven-repo}";
      jdk = lib.versions.major (lib.getVersion jdk);
    } ''
    substituteAll ${./gradle.properties.in} $out
  '';

  nix-android-repo = callPackage ./nix-android-repo.nix {
    inherit gradle jdk maven-repo;
  };

  maven-repo = buildMavenRepo {
    inherit repos;
    deps = builtins.fromJSON (builtins.readFile ./deps.json);
    fetchSources = true;
  };

  update-locks = callPackage ./update-locks.nix {
    inherit (pkgs.haskellPackages) xml-to-json-fast;
    inherit gradle repos;
    fetchSources = true;
  };
}
