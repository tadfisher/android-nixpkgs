{ pkgs }:

with pkgs;

# Configure your development environment.
#
# Documentation: https://github.com/numtide/devshell
mkDevShell {
  name = "android-project";
  motd = ''
    Entered the Android app development environment.
  '';
  env = {
    ANDROID_HOME = "${android-sdk}/share/android-sdk";
    ANDROID_SDK_ROOT = "${android-sdk}/share/android-sdk";
    JAVA_HOME = jdk11.home;
  };
  packages = [
    android-studio
    android-sdk
    gradle
    jdk11
  ];
}
