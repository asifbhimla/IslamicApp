# Adding the Athan notification sound

The app schedules a local notification at each of the five daily prayer times.
When **Settings → Play Athan sound** is on, the notification plays a bundled
Athan recitation instead of the default chime. You need to supply that audio
file for each platform (a real Athan recording isn't shipped in the repo).

Both platforms fall back to the default system sound if the file is absent, so
the app builds and runs fine before you add them — you just won't hear the
Athan until you do.

---

## 1. Get an Athan audio clip

Use a royalty-free / properly licensed Athan recording. A short clip works
best (≈30–60 seconds). iOS **requires ≤ 30 seconds** for a custom notification
sound, so trim accordingly.

Recommended: prepare one ~30 s clip and export it to both formats below.

---

## 2. Android

1. Convert the clip to MP3 (or OGG/WAV).
2. Save it as:

       android/app/src/main/res/raw/athan.mp3

   The filename must be lowercase (`athan.mp3`). The code looks it up by the
   base name `athan`.
3. Rebuild: `flutter clean && flutter build appbundle --release`

> Android binds a notification channel's sound when the channel is first
> created, so this feature uses a dedicated channel (`athan_channel_sound`).
> Because the app isn't live yet this is a non-issue, but if you ever change
> the sound later you'll need to bump that channel id (or clear app data) for
> the change to take effect on existing installs.

---

## 3. iOS

iOS custom notification sounds must be **≤ 30 seconds** and in CAF, AIFF, or
WAV format.

1. Convert the clip to AIFF named `athan.aiff` (the code references this name).
   With ffmpeg:

       ffmpeg -i athan.mp3 -t 30 -c:a pcm_s16be athan.aiff

2. Add it to the Runner target in Xcode:
   - `open ios/Runner.xcworkspace`
   - Drag `athan.aiff` into the **Runner** folder in the project navigator
   - In the dialog, check **Copy items if needed** and tick the **Runner**
     target under "Add to targets"
3. Rebuild: `flutter build ipa --release`

To verify it's bundled: select `athan.aiff` in Xcode and confirm **Target
Membership → Runner** is checked in the File Inspector.

---

## 4. Test it

- Set a prayer time a minute or two ahead (temporarily change your device
  clock, or pick a location whose next prayer is imminent).
- Make sure **Athan notifications** and **Play Athan sound** are both on in
  Settings.
- Lock the phone and wait — the notification should fire with the Athan sound.

On Android, the sound plays at **alarm** volume (so it's heard even when the
ringer is low). Make sure the device isn't in a Do-Not-Disturb mode that
suppresses alarms during testing.
