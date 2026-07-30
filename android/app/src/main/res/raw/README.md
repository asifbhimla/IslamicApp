# Athan notification sound (Android)

Place the Athan audio file here named exactly:

    athan.mp3

Requirements / notes:
- Lowercase letters, digits and underscores only in the filename (Android
  resource naming rule). `athan.mp3` is fine.
- The code references it by name (`RawResourceAndroidNotificationSound('athan')`),
  so keep the base name `athan`. `.mp3`, `.ogg`, or `.wav` all work.
- Keep it reasonably short (≈30–60 s). Very long clips may be cut off by some
  Android versions / OEMs when played as a notification sound.
- If this file is missing, notifications still work — they just use the
  default system sound.

After adding the file, rebuild the app (`flutter clean && flutter build ...`)
so the new resource is bundled.
