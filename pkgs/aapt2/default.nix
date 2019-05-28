{ stdenv, fetchurl, autoPatchelfHook, patchelf, unzip }:

stdenv.mkDerivation rec {
  name = "aapt2-${version}";
  version = "3.5.0-alpha13-5435860";

  src = fetchurl {
    url = "https://maven.google.com/com/android/tools/build/aapt2/${version}/aapt2-${version}-linux.jar";
    sha256 = "0d373bih9nzkw8ng1hs6g7l1322njf0knnkx78j5dss6ai3g3vi0";
  };

  nativeBuildInputs = [ autoPatchelfHook patchelf unzip ];

  unpackCmd = "unzip $curSrc -d ${name}";

  installPhase = ''
    mkdir -p $out/bin
    cp aapt2 $out/bin
    chmod +x $out/bin/aapt2

    patchelf --set-interpreter ${stdenv.cc.libc.out}/lib/ld-linux-x86-64.so.2 $out/bin/aapt2

    # mkdir -p $out/lib
    # cp lib64/libc++.so $out/lib
    # chmod +x $out/lib/libc++.so
  '';

  meta = with stdenv.lib; {
    description = "Android Asset Packaging Tool";
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.tadfisher ];
    license = licenses.asl20;
  };
}
