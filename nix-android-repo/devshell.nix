{ devshellPkgs
, gradle
, gradle2nix
, jdk
, update-locks
}:

devshellPkgs.mkShell {
  name = "android-nixpkgs";

  env = [
    {
      name = "JAVA_HOME";
      eval = "${jdk.home}";
    }
  ];

  packages = [
    gradle
    gradle2nix
    jdk
  ];

  commands = [
    {
      name = "update-locks";
      help = "Update dependency lockfiles.";
      category = "development";
      package = update-locks;
    }
  ];
}
