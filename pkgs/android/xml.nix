{ writeTextFile, licenses }:

name: outdir: package:

let

in writeTextFile {
  name = "${name}-package-xml";
  destination = "/${outdir}/package.xml";
  text = ''
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <sdk:repository
        xmlns:common="http://schemas.android.com/repository/android/common/01"
        xmlns:generic="http://schemas.android.com/repository/android/generic/01"
        xmlns:addon="http://schemas.android.com/sdk/android/repo/addon2/01"
        xmlns:sdk="http://schemas.android.com/sdk/android/repo/repository2/01"
        xmlns:sys-img="http://schemas.android.com/sdk/android/repo/sys-img2/01">
      <license id="${package.license}" type="text">${licenses.${package.license}}</license>

    </sdk:repository>"
  '';
}
