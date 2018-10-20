{ stdenv, mkGeneric }:

let
  inherit (builtins) head listToAttrs match split;
  inherit (stdenv.lib) last mapAttrs;

  repos = {
    android = {
      path = "android";
      packages = import ./repo/sys-img-android.nix;
    };
    androidTv = {
      path = "android-tv";
      packages = import ./repo/sys-img-android-tv.nix;
    };
    androidWear = {
      path = "android-wear";
      packages = import ./repo/sys-img-android-wear.nix;
    };
    androidWearChina = {
      path = "android-wear-cn";
      packages = import ./repo/sys-img-android-wear-cn.nix;
    };
    googleApis = {
      path = "google_apis";
      packages = import ./repo/sys-img-google_apis.nix;
    };
    googleApisPlayStore = {
      path = "google_apis_playstore";
      packages = import ./repo/sys-img-google_apis_playstore.nix;
    };
  };

  pname = p:
    let
      sdk = head (match ".*;android-([[:digit:]]+);.*" p.path);
      arch = last (split ";" p.path);
    in
      "${arch}-${sdk}";

in mapAttrs (name: repo:
  let
    repoUrl = "https://dl.google.com/android/repository/sys-img/${repo.path}";
  in listToAttrs (map (p: {
    name = pname p;
    value = mkGeneric {
      package = p;
      inherit repoUrl;
    };
  }) repo.packages)
) repos
