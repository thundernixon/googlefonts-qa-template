#!/bin/bash

# This script copies the latest builds to the google fonts dir in order to run QA checks and prep for a PR
# 
# The PR portion-update assumes you are already part of the googlefonts org on GitHub
#
# USAGE: 
# 1. Install requirements with `pip install -U -r googlefonts-qa/requirements.txt`
# 
# 2. Update the variables in the first section
# 
# 3. If this is your first time running the move, 
# 
# 4. call this script from the root of your font project repo, with the absolute path your your local google/fonts repo
#    `move-check /Users/YOUR_LOCAL_USERNAME/PATH/fonts`

# -------------------------------------------------------------------
# UPDATE THESE VARIABLES AS NEEDED ----------------------------------

# replace "FONTNAME" with appropriate name and make sure path is correct
thisVF="$thisDir/distr/variable_ttf/FONTNAME-VF.ttf"

# replace "fontname" with an all-lowercase, no-spaces family name
familyname="fontname"

# Where checks are saved. Don't edit this if you have a "googlefonts-qa" at top level in the project. 
thisQADir="$thisDir/googlefonts-qa"

# -------------------------------------------------------------------
# sets up script and check for required argument --------------------

set -ex
source venv/bin/activate
gFontsDir=$1

if [[ -z "$gFontsDir" || $gFontsDir = "--help" ]] ; then
    echo 'Add absolute path to your Google Fonts Git directory, like:'
    echo 'googlefonts-qa/scripts/move-check.sh /Users/YOUR_LOCAL_USERNAME/PATH/fonts'
    exit 2
fi

thisDir=$(pwd)

# -------------------------------------------------------------------
# gets latest version -----------------------------------------------

ttx -t head $thisVF
fontVersion=v$(xml sel -t --match "//*/fontRevision" -v "@value" ${thisVF/".ttf"/".ttx"})
rm ${thisVF/".ttf"/".ttx"}

# -------------------------------------------------------------------
# navigates to google/fonts repo, then font family branch -----------

cd $gFontsDir
git checkout master
git pull upstream master
git reset --hard
git checkout -B $familyname
git clean -f -d

# -------------------------------------------------------------------
# moves fonts -------------------------------------------------------

mkdir -p ofl/$familyname

cp $thisVF    ofl/$familyname/$(basename $thisVF)

mkdir -p ofl/$familyname/static
statics=$(ls $thisDir/distr/ttf/*.ttf)
for ttf in $statics
do
    cp $ttf ofl/$familyname/static/$(basename $ttf)
done

# -------------------------------------------------------------------
# makes or moves basic metadata -------------------------------------

# only runs if there is not yet a metadata file. 
if [ ! -f ofl/$familyname/METADATA.pb ]; then
    echo "No metadata file yet."
    gftools add-font ofl/$familyname
    cp ofl/$familyname/METADATA.pb $thisDir/googlefonts-qa/METADATA.pb 
    echo "You must update the font metadata file at $thisDir/googlefonts-qa/METADATA.pb"
fi

cp $thisDir/googlefonts-qa/METADATA.pb ofl/$familyname/METADATA.pb

cp $thisDir/LICENSE ofl/$familyname/OFL.txt

cp $thisQADir/gfonts-description.html ofl/$familyname/DESCRIPTION.en_us.html

# -------------------------------------------------------------------
# runs checks, saving to $familyname/googlefonts-qa/checks ----------

set +e # otherwise, the script stops after the first fontbakery check output

mkdir -p $thisQADir/checks/static

cd ofl/$familyname

ttfs=$(ls -R */*.ttf && ls *.ttf) # use this to statics and VFs
# ttfs=$(ls *.ttf) # use this to check only the VFs
# ttfs=$(ls -R */*.ttf ) # use this to check only statics

for ttf in $ttfs
do
    echo $ttf
    fontbakery check-googlefonts $ttf --ghmarkdown $thisQADir/checks/${ttf/".ttf"/".checks.md"}
done

git add .
git commit -m "$familyname: $fontVersion added."

git push --force upstream $familyname
