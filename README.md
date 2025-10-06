NFC Reader Tool - Source bundle (README)
======================================

What you received
-----------------
This archive contains the minimal source files and instructions to build the iOS app "NFC Reader Tool".
The archive is NOT a ready-to-install .ipa. Due to platform limitations I cannot send a pre-signed .ipa here.
However, this source is ready to be placed into an Xcode project and built into an .ipa which you can then
install on your iPhone (iPhone 12 Pro Max, iOS 18.6.2) using AltStore or a Mac.

Files included:
- ViewController.swift    -> main UI + NFC reading code (CoreNFC)
- Info.plist              -> minimal plist entries (update bundle id before build)
- README.md               -> this file

Important notes (make sure to follow these exactly):
1) This app requires the "Near Field Communication Tag Reading" capability enabled in Xcode. Before building, in Xcode:
   - Select your project target -> Signing & Capabilities -> +Capability -> Near Field Communication Tag Reading
   - Add your Apple Development Team under Signing & Capabilities (a free Apple ID can be used for development/testing).

2) iOS deployment target: set to 13.0 or later (we used APIs available in iOS 13+).

3) Bundle identifier: change the CFBundleIdentifier in Info.plist (and in Xcode target) to a reverse-domain you control
   (e.g., com.YOURNAME.NFCReaderTool) to avoid conflicts.

4) To build on a Mac:
   - Create a new Xcode "App" project (Single View Application / UIKit App).
   - Replace the default ViewController.swift with the provided file (or add it).
   - Replace project's Info.plist content or merge required keys.
   - Enable "Near Field Communication Tag Reading" capability.
   - Build & run on a connected iPhone (requires a Mac). To export an .ipa:
       Product -> Archive -> Distribute App -> Ad Hoc or Development -> Export as .ipa (choose automatic signing with your Apple ID / team).

5) To install without a Mac (using a .ipa):
   - You still need an .ipa produced by a Mac or a cloud macOS builder (or someone who can build it for you).
   - Once you have the .ipa, use AltStore on your Windows PC to install:
       - Install AltServer on Windows: https://altstore.io
       - Connect your iPhone by USB and use AltServer -> Install AltStore -> [your iPhone]
       - On iPhone, trust your Apple ID certificate in Settings > General > VPN & Device Management
       - In AltStore on iPhone: My Apps -> + -> select the .ipa to install
     AltStore will sign the app with your Apple ID and install it like a normal app.

6) Offline behavior: The app does not require network access. It only uses CoreNFC to read tag data locally.

Safety / Reliability constraints (what the app DOES and DOES NOT do)
-------------------------------------------------------------------
- DOES:
  - Read identifier (UID) from tags (ISO 14443, ISO 15693, ISO7816, FeliCa when supported)
  - Display UID as hex, decimal (big-endian) and decimal (reversed bytes)
  - Show reliable, non-invasive info (type, uid length and a couple of fields for ISO15693/ISO7816)
  - Use dark theme by default (black background, light text)

- DOES NOT:
  - Perform tag writing or invoke manufacturer-specific commands (to avoid errors)
  - Attempt privileged operations that require special entitlements
  - Collect or transmit data off the device (offline use only)

If you prefer, I can:
- Provide instructions to get a friend with a Mac to build the .ipa for you (I will give them exact steps).
- Create a simple GitHub repo layout with the full project so someone with Mac can click Build.
- Walk you step-by-step through using AltStore once you have a .ipa.

Next steps (choose one)
-----------------------
1) I prepare a GitHub repo layout (source + instructions) so you or someone else can build the .ipa.
2) I walk you step-by-step to get a friend with a Mac to produce the .ipa from this source.
3) I attempt to produce a cloud-based build instruction (requires you to provide an Apple Developer Team ID and/or upload signing certs — not recommended for security).

Tell me which option you prefer. If you want, I can create a GitHub-ready zip now (ready to push).

