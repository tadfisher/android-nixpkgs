{ stdenv, fetchurl, unzip }:

{ sources
, repoUrl ? https://dl.google.com/android/repository
, ... } @ args:

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

in (fetchurl ({
  url = "${repoUrl}/${src.url}";
  inherit (src) sha1;
} // removeAttrs args [ "sources" "repoUrl" ]))
