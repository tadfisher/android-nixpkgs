{ lib
, stdenv
, devshell
, gradle
, gradle-properties
, jdk
, update-locks
}:

with lib;

devshell.mkShell {
  name = "android-nixpkgs";

  env = [
    {
      name = "JAVA_HOME";
      eval = "${jdk.home}";
    }
  ];

  packages = [
    gradle
    jdk
  ];

  devshell.startup = {
    gradle-properties.text = ''
      rm -f $PRJ_ROOT/nix-android-repo/gradle.properties
      ln -sf ${gradle-properties} $PRJ_ROOT/nix-android-repo/gradle.properties
    '';
  };

  commands = [
    {
      name = "update-locks";
      help = "Update dependency lockfiles.";
      category = "development";
      package = update-locks;
    }
  ];
}
