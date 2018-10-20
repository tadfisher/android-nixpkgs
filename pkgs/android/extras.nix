{ stdenv, mkGeneric
, autoPatchelfHook
}:

let
  inherit (builtins) filter hasAttr isAttrs match split;
  inherit (stdenv.lib) findSingle foldr hasPrefix init last mapAttrsRecursiveCond recursiveUpdate setAttrByPath;

  packages = filter (p: hasPrefix "extras;" p.path) (import ./repo/addon.nix);

  packageAttrs = foldr (p: attrs:
    let
      path = filter (x: x != []) (split ";" p.path);
      merged = if match "[[:digit:]].*" (last path) then
        (init path)
    in
      recursiveUpdate attrs (setAttrByPath path p)
  ) {} packages;

in
  (mapAttrsRecursiveCond (as: !(hasAttr "path" as)) (path: package: mkGeneric { inherit package; }) packageAttrs).extras
