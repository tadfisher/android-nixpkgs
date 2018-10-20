self: super:
let
  inherit (builtins) length replaceStrings;
  inherit (super) sublist take;
in rec {
  versionAsPath = ver: replaceStrings ["."] ["-"] ver;

  takeLast = count: list:
    sublist (length list - count) count list;

  prefixedBy = other: list:
    take (length other) list == other;

  suffixedBy = other: list:
    takeLast (length other) list == other;
}
