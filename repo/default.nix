builtins.concatLists (map (path: import path) [
  ./addon.nix 
  ./extras-intel.nix 
  ./glass.nix 
  ./repository.nix 
  ./sys-img-android-tv.nix 
  ./sys-img-android-wear-cn.nix 
  ./sys-img-android-wear.nix 
  ./sys-img-android.nix 
  ./sys-img-google_apis.nix 
  ./sys-img-google_apis_playstore.nix
])
