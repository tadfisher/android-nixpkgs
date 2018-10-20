#!/bin/sh -e

repo="$1"
if [ ! -d "$repo" ]; then
    echo "usage: $(basename $0) repository-dir [out-dir]"
    exit 1
fi

out="$2" || $(pwd)
script=$(dirname $(realpath $0))

xsltproc --stringparam os linux "$script/gen-tools.xsl" "$repo/repository2-1.xml" > "$out/repository.nix"
xsltproc --stringparam os linux "$script/gen-tools.xsl" "$repo/addon2-1.xml" > "$out/addon.nix"
xsltproc --stringparam os linux "$script/gen-tools.xsl" "$repo/extras/intel/addon2-1.xml" > "$out/extras-intel.nix"
xsltproc --stringparam os linux "$script/gen-tools.xsl" "$repo/glass/addon2-1.xml" > "$out/glass.nix"

for d in "$repo"/sys-img/*; do
  xsltproc --stringparam os linux "$script/gen-tools.xsl" "$d/sys-img2-1.xml" > "$out/sys-img-$(basename "$d").nix"
done
