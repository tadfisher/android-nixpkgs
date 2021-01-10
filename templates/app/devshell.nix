{ pkgs }:

with pkgs;

# Configure your development environment.
#
# Documentation: https://github.com/numtide/devshell
mkDevShell {
  name = "android-app";
  motd = ''
    Entered the Android app development environment.

    Available commands:

  '';
  env = {
    JAVA_HOME = ;
  };
  packages = [
    # Select a version of Android Studio.
    android-studio
    # androidStudioPackages.beta
    # androidStudioPackages.canary
    # androidStudioPackages.dev

    # Configure SDK packages in flake.nix.
    android-sdk

    gradle
    jdk11
  ];
}
