#!/bin/sh

# -------------------------------------------------------------------
# UPDATE THIS VARIABLE ----------------------------------------------

thisFont="YourFontFamilyName" # must match the name in the font file, e.g. FiraCode-VF.ttf needs the variable "FiraCode"

# -------------------------------------------------------------------
# Update the following as needed ------------------------------------

source venv/bin/activate
set -e

cd sources

echo "Generating Static fonts"
mkdir -p ../fonts/ttfs
fontmake -g $thisFont-Roman.glyphs -i -o ttf --output-dir ../fonts/ttfs/
fontmake -g $thisFont-Italic.glyphs -i -o ttf --output-dir ../fonts/ttfs/

echo "Generating VFs"
mkdir -p ../fonts/variable
fontmake -g $thisFont-Roman.glyphs -o variable --output-path ../fonts/variable/$thisFont-Roman-VF.ttf
fontmake -g $thisFont-Italic.glyphs -o variable --output-path ../fonts/variable/$thisFont-Italic-VF.ttf

rm -rf master_ufo/ instance_ufo/

echo "Post processing"

ttfs=$(ls ../fonts/ttfs/*.ttf)
echo $ttfs
for ttf in $ttfs
do
	gftools fix-dsig --autofix $ttf;
	gftools fix-nonhinting $ttf $ttf;
done
rm ../fonts/ttfs/*backup*.ttf

vfs=$(ls ../fonts/variable/*.ttf)
for vf in $vfs
do
	gftools fix-dsig --autofix $vf;
	gftools fix-nonhinting $vf $vf
done
rm ../fonts/variable/*backup*.ttf

gftools fix-vf-meta $vfs;
for vf in $vfs
do
	mv "$vf.fix" $vf;
done

cd ..

# ============================================================================
# Autohinting ================================================================

statics=$(ls fonts/ttfs/*.ttf)
echo hello
for file in $statics; do 
    echo "fix DSIG in " ${file}
    gftools fix-dsig --autofix ${file}

    echo "TTFautohint " ${file}
    # autohint with detailed info
    hintedFile=${file/".ttf"/"-hinted.ttf"}
    ttfautohint -I ${file} ${hintedFile} 
    cp ${hintedFile} ${file}
    rm -rf ${hintedFile}
done


# ============================================================================
# Build woff2 fonts ==========================================================

# requires https://github.com/bramstein/homebrew-webfonttools

rm -rf fonts/woff2

ttfs=$(ls fonts/*/*.ttf)
for ttf in $ttfs; do
    woff2_compress $ttf
done

mkdir -p fonts/woff2
woff2s=$(ls fonts/*/*.woff2)
for woff2 in $woff2s; do
    mv $woff2 fonts/woff2/$(basename $woff2)
done
# ============================================================================
# Build woff fonts ==========================================================

# requires https://github.com/bramstein/homebrew-webfonttools

rm -rf fonts/woff

ttfs=$(ls fonts/*/*.ttf)
for ttf in $ttfs; do
    sfnt2woff-zopfli $ttf
done

mkdir -p fonts/woff
woffs=$(ls fonts/*/*.woff)
for woff in $woffs; do
    mv $woff fonts/woff/$(basename $woff)
done