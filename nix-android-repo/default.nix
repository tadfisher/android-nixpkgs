{ devshellPkgs
, gradle2nixBuilders
, gradle2nixPkgs
, pkgs
}:

let
  inherit (gradle2nixBuilders) buildGradlePackage;
  inherit (gradle2nixPkgs) gradle2nix;
  inherit (pkgs) callPackage jdk;
in
rec {
  devshell = callPackage ./devshell.nix {
    inherit devshellPkgs gradle2nix jdk update-locks;
  };

  nix-android-repo = callPackage ./nix-android-repo.nix {
    inherit buildGradlePackage jdk;
  };

  update-locks = callPackage ./update-locks.nix {
    inherit gradle2nix;
  };
}
