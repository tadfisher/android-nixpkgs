{ stdenv, fetchurl, autoPatchelfHook, patchelf, unzip }:

stdenv.mkDerivation rec {
  name = "aapt2-${version}";
  version = "4.1.0-6503028";

  src = fetchurl {
    url = "https://maven.google.com/com/android/tools/build/aapt2/${version}/aapt2-${version}-linux.jar";
    sha256 = "11n0nn1hzvi1c5dpbff4wsrcczcbkc4ykwkvh22vywc9jv5l26d3";
  };

  nativeBuildInputs = [ autoPatchelfHook patchelf unzip ];

  unpackCmd = "unzip $curSrc -d ${name}";

  installPhase = ''
    mkdir -p $out/bin
    cp aapt2 $out/bin
    chmod +x $out/bin/aapt2

    patchelf --set-interpreter ${stdenv.cc.libc.out}/lib/ld-linux-x86-64.so.2 $out/bin/aapt2
  '';

  meta = with stdenv.lib; {
    description = "Android Asset Packaging Tool";
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.tadfisher ];
    license = licenses.asl20;
  };
}
