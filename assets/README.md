# Assets

## Folder Structure

```
assets/
├── fonts/
│   ├── Nunito-Regular.ttf       ← Download manually (see below)
│   ├── Nunito-Medium.ttf
│   ├── Nunito-SemiBold.ttf
│   ├── Nunito-Bold.ttf
│   ├── Nunito-ExtraBold.ttf
│   └── download_fonts.sh        ← Run this to auto-download
│
├── images/
│   ├── app_logo.svg             ✅ Included
│   ├── empty_groups.svg         ✅ Included
│   └── empty_expenses.svg       ✅ Included
│
├── icons/
│   ├── ic_google.svg            ✅ Included
│   └── ic_categories.svg        ✅ Included
│
└── animations/
    ├── success.json             ✅ Included (Lottie)
    ├── loading.json             ✅ Included (Lottie)
    └── empty_state.json         ✅ Included (Lottie)
```

---

## 🔤 Fonts — Nunito

### Option A: Auto-download (recommended)
```bash
cd assets/fonts
chmod +x download_fonts.sh
./download_fonts.sh
```

### Option B: Manual download
1. Go to https://fonts.google.com/specimen/Nunito
2. Click **"Download family"**
3. Unzip and copy these files into `assets/fonts/`:
   - `Nunito-Regular.ttf`
   - `Nunito-Medium.ttf`
   - `Nunito-SemiBold.ttf`
   - `Nunito-Bold.ttf`
   - `Nunito-ExtraBold.ttf`

### Option C: Use google_fonts package (no files needed)
Add to `pubspec.yaml`:
```yaml
dependencies:
  google_fonts: ^6.1.0
```
Then in `app_theme.dart` replace `fontFamily: 'Nunito'` with:
```dart
import 'package:google_fonts/google_fonts.dart';
// Use: GoogleFonts.nunito() wherever needed
```

---

## 🎬 Animations (Lottie)

The `.json` files included are basic placeholders.  
For polished animations, download free ones from:
- https://lottiefiles.com/search?q=success
- https://lottiefiles.com/search?q=loading
- https://lottiefiles.com/search?q=empty+state

Replace the files at the same paths.

---

## 🖼 Images & Icons

SVG files are included and rendered via `flutter_svg`.  
Make sure `flutter_svg` is in your `pubspec.yaml` (it is already).
