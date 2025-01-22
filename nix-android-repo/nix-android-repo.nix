{ buildGradlePackage
, makeWrapper
, jdk
}:

buildGradlePackage {
  pname = "nix-android-repo";
  version = "0.0.1";

  src = ./.;

  lockFile = ./gradle.lock;

  buildJdk = jdk;

  nativeBuildInputs = [ makeWrapper ];

  gradleBuildFlags = [ ":installDist" ];

  installPhase = ''
    mkdir -p $out
    cp -r build/install/nix-android-repo/* $out
  '';

  postFixup = ''
    wrapProgram $out/bin/nix-android-repo --set-default JAVA_HOME ${jdk.home}
  '';
}
