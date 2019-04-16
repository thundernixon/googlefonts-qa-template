source venv/bin/activate

# -------------------------------------------------------------------
# UPDATE THIS VARIABLE ----------------------------------------------

thisFont="YourFontFamilyName" # must match the name in the font file, e.g. FiraCode-VF.ttf needs the variable "FiraCode"

# -------------------------------------------------------------------
# adjust as needed --------------------------------------------------

fontbakery check-googlefonts fonts/variable/$thisFont-Italic-VF.ttf --ghmarkdown checks/$thisFont-Italic-VF.md
fontbakery check-googlefonts fonts/variable/$thisFont-Roman-VF.ttf --ghmarkdown checks/$thisFont-Roman-VF.md