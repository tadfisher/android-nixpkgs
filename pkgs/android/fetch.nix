{ stdenv, fetchurl, unzip }:

{ sources, ... } @ args:
let
  # Keys by which to search the package's "sources" set for the host platform.
  hostOsKeys = with stdenv.hostPlatform; [
    system
    parsed.kernel.name
    parsed.cpu.name
    "all"
  ];

  platformKey = stdenv.lib.findFirst
    (k: builtins.hasAttr k sources)
    (throw "Unsupported system: ${stdenv.hostPlatform.system}")
    hostOsKeys;

  src = sources.${platformKey};

in
(fetchurl ({
  inherit (src) url sha1;
} // removeAttrs args [ "sources" ]))
