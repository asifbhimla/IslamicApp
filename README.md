# Islamic App

A Flutter app for Android and iOS that serves as a daily Islamic companion:

- **Prayer times & Athan** — accurate times calculated locally on the device
  with [adhan_dart](https://pub.dev/packages/adhan_dart), based on your GPS
  location (falls back to Makkah until location permission is granted). A live
  countdown shows the next prayer, and local notifications fire at each prayer
  time. 13 calculation methods (Muslim World League, ISNA, Umm Al-Qura,
  Karachi, …) and both Asr conventions (standard / Hanafi) are supported.
- **Quran reading** — the complete Quran (114 surahs, Arabic text with the
  Saheeh International English translation) is bundled with the app and works
  fully offline. Searchable surah list and adjustable Arabic text size.
- **Duas** — a curated collection of authentic daily supplications from the
  Quran and Hisnul Muslim, organised by category, with Arabic text,
  transliteration, translation, and source.
- **Hijri calendar** — month grid with Gregorian dates overlaid, notable
  Islamic dates highlighted (Ramadan, both Eids, Day of Arafah, Ashura, …)
  and a list of upcoming events.

Everything runs on-device; the app makes no network calls.

## Project layout

```
lib/
  main.dart                     App entry point and theme
  app_state.dart                Settings + prayer time calculation (provider)
  data/
    duas_data.dart              Bundled dua collection
    islamic_events.dart         Notable Hijri dates
  services/
    location_service.dart       GPS lookup (geolocator)
    notification_service.dart   Athan scheduling (flutter_local_notifications)
  screens/
    root_screen.dart            Bottom navigation
    home_screen.dart            Next-prayer countdown + today's times
    quran_screen.dart           Surah list with search
    surah_detail_screen.dart    Verse-by-verse reading view
    duas_screen.dart            Dua categories and detail cards
    calendar_screen.dart        Hijri month view + events
    settings_screen.dart        Location, method, madhab, notifications
```

## Getting started

1. [Install Flutter](https://docs.flutter.dev/get-started/install) (3.35+).
2. Fetch dependencies and run:

   ```sh
   flutter pub get
   flutter run
   ```

3. Run the checks:

   ```sh
   flutter analyze
   flutter test
   ```

### Release builds

- **Android:** `flutter build apk` (or `appbundle` for Play Store). Add your
  own signing config in `android/app/build.gradle.kts` first.
- **iOS:** `flutter build ios` on macOS with Xcode, then archive via Xcode.
  Set your development team on the Runner target.

## Notes & possible next steps

- Hijri dates come from an arithmetic calendar and can differ by ±1 day from
  local moon sighting; the calendar screen states this.
- Notifications currently use the system default sound. Bundling an actual
  athan audio file (custom notification sound) is a natural next step.
- Other ideas: Qibla compass, tasbih counter, more translations, verse
  bookmarks, audio recitation.
