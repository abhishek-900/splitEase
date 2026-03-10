#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# Nunito Font Downloader
# Run this script from the project root to download all required
# Nunito font weights into assets/fonts/
# ─────────────────────────────────────────────────────────────────

FONT_DIR="assets/fonts"
BASE_URL="https://fonts.gstatic.com/s/nunito/v26"

echo "📦 Downloading Nunito fonts into $FONT_DIR ..."

declare -A FONTS=(
  ["Nunito-Regular.ttf"]="ZCPM6nIzNTRkMI9sjbiL5tIUFg"
  ["Nunito-Medium.ttf"]="ZCPM6nIzNTRkMI9sjbiL5tIU"
  ["Nunito-SemiBold.ttf"]="ZCPM6nIzNTRkMI9sjbiL5tIU"
  ["Nunito-Bold.ttf"]="ZCPM6nIzNTRkMI9sjbiL5tIU"
  ["Nunito-ExtraBold.ttf"]="ZCPM6nIzNTRkMI9sjbiL5tIU"
)

# Easiest: use flutter pub to fetch via google_fonts or direct download
# Option A: Use curl with Google Fonts API
API_KEY=""  # Add your Google Fonts API key if needed

echo ""
echo "⚡ QUICKEST METHOD — Run this Flutter command instead:"
echo ""
echo "   Add 'google_fonts: ^6.1.0' to pubspec.yaml dev_dependencies"
echo "   Then replace fontFamily: 'Nunito' with GoogleFonts.nunito() calls"
echo ""
echo "─── OR ─────────────────────────────────────────────────────────"
echo ""
echo "📥 MANUAL DOWNLOAD:"
echo "   1. Go to: https://fonts.google.com/specimen/Nunito"
echo "   2. Click 'Download family'"
echo "   3. Extract and copy these files into assets/fonts/:"
echo ""
echo "      Nunito-Regular.ttf     (weight 400)"
echo "      Nunito-Medium.ttf      (weight 500)"
echo "      Nunito-SemiBold.ttf    (weight 600)"
echo "      Nunito-Bold.ttf        (weight 700)"
echo "      Nunito-ExtraBold.ttf   (weight 800)"
echo ""
echo "─── OR ─────────────────────────────────────────────────────────"
echo ""
echo "🤖 AUTO DOWNLOAD via curl:"

curl -L "https://fonts.google.com/download?family=Nunito" -o /tmp/Nunito.zip 2>/dev/null

if [ $? -eq 0 ]; then
  unzip -o /tmp/Nunito.zip -d /tmp/Nunito_extracted/ 2>/dev/null

  # Copy specific weights
  WEIGHTS=("Regular" "Medium" "SemiBold" "Bold" "ExtraBold")
  for weight in "${WEIGHTS[@]}"; do
    FILE=$(find /tmp/Nunito_extracted -name "Nunito-${weight}.ttf" 2>/dev/null | head -1)
    if [ -n "$FILE" ]; then
      cp "$FILE" "$FONT_DIR/Nunito-${weight}.ttf"
      echo "   ✅ Nunito-${weight}.ttf"
    else
      echo "   ❌ Nunito-${weight}.ttf not found — add manually"
    fi
  done

  rm -rf /tmp/Nunito.zip /tmp/Nunito_extracted
  echo ""
  echo "✅ Done! Run 'flutter pub get' to apply fonts."
else
  echo "   Could not auto-download. Please download manually from:"
  echo "   https://fonts.google.com/specimen/Nunito"
fi
