#! /usr/bin/env nix-shell
#! nix-shell -i bash -p libxslt

set -e
shopt -s extglob

repo="$1"
if [ ! -d "$repo" ]; then
    echo "usage: $(basename $0) repository-dir [out-dir]"
    exit 1
fi

out="$2" || $(pwd)
script=$(dirname $(realpath $0))

xsltproc --stringparam os linux "$script/generate.xsl" "$repo/repository2-1.xml" > "$out/repository.nix"
xsltproc --stringparam os linux "$script/generate.xsl" "$repo/addon2-1.xml" > "$out/addon.nix"
xsltproc --stringparam os linux "$script/generate.xsl" "$repo/extras/intel/addon2-1.xml" > "$out/extras-intel.nix"
xsltproc --stringparam os linux "$script/generate.xsl" "$repo/glass/addon2-1.xml" > "$out/glass.nix"

for d in "$repo"/sys-img/*; do
  xsltproc --stringparam os linux "$script/generate.xsl" "$d/sys-img2-1.xml" > "$out/sys-img-$(basename "$d").nix"
done

rm "$out/default.nix" 2>/dev/null || true

pushd "$out" >/dev/null

nixfiles=( ./*.nix )

cat >"$out/default.nix" <<EOF
builtins.concatLists (map (path: import path) [$(echo "${nixfiles[@]/#/$'\n'  }")
])
EOF

popd >/dev/null
