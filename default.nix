{ pkgs ? import <nixpkgs> { }
, system ? pkgs.stdenv.system
, channel ? "stable"
}:

with pkgs;
let
  androidSdk = callPackage ./pkgs/android { };

  getName = attrs: attrs.name or ("${attrs.pname or "«name-missing»"}-${attrs.version or "«version-missing»"}");

  isMarkedInsecure = attrs: (attrs.meta.knownVulnerabilities or [ ]) != [ ];
  allowInsecureDefaultPredicate = x: builtins.elem (getName x) (config.permittedInsecurePackages or [ ]);
  allowInsecurePredicate = x: (config.allowInsecurePredicate or allowInsecureDefaultPredicate) x;
  hasAllowedInsecure = attrs:
    !(isMarkedInsecure attrs) ||
    allowInsecurePredicate attrs ||
    builtins.getEnv "NIXPKGS_ALLOW_INSECURE" == "1";

  isMarkedBroken = attrs: attrs.meta.broken or false;
  allowBroken = config.allowBroken || builtins.getEnv "NIXPKGS_ALLOW_BROKEN" == "1";
  hasAllowedBroken = attrs:
    !(isMarkedBroken attrs) || allowBroken;

  allowUnsupportedSystem = config.allowUnsupportedSystem
    || builtins.getEnv "NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM" == "1";

  isSupported = pkg:
    lib.meta.availableOn hostPlatform pkg || allowUnsupportedSystem;

  filterIsSupported = lib.filterAttrs (_: pkg:
    (!lib.isDerivation pkg) || (
      isSupported pkg &&
      hasAllowedBroken pkg &&
      hasAllowedInsecure pkg
    )
  );

  channelPkgs = rec {
    stable = filterIsSupported (androidSdk.callPackage ./channels/stable { });
    beta = filterIsSupported (androidSdk.callPackage ./channels/beta { });
    preview = filterIsSupported (androidSdk.callPackage ./channels/preview { });
    canary = filterIsSupported (androidSdk.callPackage ./channels/canary { });
  };

in
rec {
  packages = channelPkgs."${channel}";
  sdk = callPackage ./pkgs/android/sdk.nix { inherit packages; };
}
