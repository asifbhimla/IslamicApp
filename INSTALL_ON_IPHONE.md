# Installing QalbCare on your iPhone without the App Store

iOS apps can only be **built on a Mac with Xcode** — that part can't be done on
Linux/Windows or in the cloud. Once built, there are a few ways to get the app
onto your iPhone without the App Store. They are listed easiest-first.

App identity (already configured):
- Display name: **QalbCare**
- Bundle id: `com.asifbhimla.islamicApp`

---

## Option 1 — Unsigned IPA + Sideloadly / AltStore (recommended, free)

This produces a `.ipa` file and lets a free tool sign it with your own Apple ID.

1. On your Mac, from the project root:
   ```bash
   ./scripts/build_ipa.sh
   ```
   This produces `build/ipa/QalbCare.ipa`.

2. Install the IPA with either tool:
   - **Sideloadly** — https://sideloadly.io — plug in the iPhone, drag in the
     IPA, enter your Apple ID, click Start.
   - **AltStore** — https://altstore.io — install AltServer on the Mac, then
     install the IPA through it.

3. On the iPhone, trust the developer profile:
   **Settings → General → VPN & Device Management → (your Apple ID) → Trust**.

Notes:
- With a **free** Apple ID the app stops opening after **7 days** and must be
  re-installed (AltStore can auto-refresh it while on Wi‑Fi).
- With a **paid** Apple Developer account ($99/yr) it lasts **1 year**.

---

## Option 2 — Run straight from Xcode (free, quickest one-off)

Good when the iPhone is plugged into the Mac.

1. ```bash
   flutter pub get
   open ios/Runner.xcworkspace
   ```
2. In Xcode: select **Runner → Signing & Capabilities**, pick your Apple ID
   under *Team* (add it via Xcode → Settings → Accounts if needed). Let Xcode
   manage signing; if the bundle id is taken, change it to something unique
   like `com.asifbhimla.qalbcare`.
3. Select your iPhone as the run target and press **Run** (▶). The app installs
   directly. Same 7‑day limit on a free account.

---

## Option 3 — Ad‑hoc IPA (paid Apple Developer account)

For sharing a signed IPA with specific devices.

1. Register each iPhone's UDID at https://developer.apple.com and create an
   **Ad Hoc** provisioning profile for the bundle id.
2. Build a signed IPA:
   ```bash
   flutter build ipa --export-method ad-hoc
   ```
   The IPA lands in `build/ios/ipa/`.
3. Install it via **Apple Configurator** (Mac) or any MDM/OTA distribution.

---

## Troubleshooting

- **"Module 'flutter_compass' not found"** or other pod errors: run
  `flutter clean && flutter pub get && cd ios && pod install --repo-update`,
  and make sure Xcode opens `Runner.xcworkspace` (not `Runner.xcodeproj`).
- **"Untrusted Developer"** when launching: do the Trust step in Option 1.3.
- **App won't open after a week**: that's the free-account 7‑day limit —
  re-install, or use AltStore's auto-refresh, or move to a paid account.
