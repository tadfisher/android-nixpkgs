{ stdenv, mkGeneric
, autoPatchelfHook, findutils, coreutils, fontconfig, freetype, libX11
, libXdamage, libXrender, libXext, libpulseaudio, ncurses5, jdk8
}:

package:

let
  inherit (builtins) listToAttrs replaceStrings;

in mkGeneric {
  inherit package;

  nativeBuildInputs = [
    autoPatchelfHook
    findutils
  ];

  buildInputs = [
    coreutils
    fontconfig
    freetype
    libX11
    libXdamage
    libXrender
    libXext
    libpulseaudio
    ncurses5
    jdk8
  ];

  postInstall = ''
    mkdir -p $out/bin
    find $out/tools -executable -type f -exec ln -s '{}' $out/bin/ \;

    for f in $(grep -l -a -r "/bin/ls" $out/tools); do
      substituteInPlace $f --replace "/bin/ls" "${coreutils}/bin/ls"
    done
  '';
}
