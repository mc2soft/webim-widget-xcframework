# WebimWidget

[WebimMobileWidget](https://github.com/webim/webim-mobile-ui-ios) and all of its
dependencies, prebuilt as `xcframework`s.

## Installation

```swift
.package( url: "https://github.com/mc2soft/webim-widget-xcframework", from: "2.0.3" )
```

and in your target's dependencies:

```swift
.product( name: "WebimWidget", package: "webim-widget-xcframework" )
```

Imports stay the same — module names are unchanged:

```swift
import WebimMobileWidget
import WebimMobileSDK
```

## Versioning

Tags mirror `WebimMobileWidget` versions: tag `2.0.3` is built from widget version 2.0.3.

Requires iOS 18 or later. The binaries are built with Xcode 27 (Swift 6.4), so the
consuming app must be built with Xcode 27 or later as well.

## Building a new version

```bash
CODESIGN_IDENTITY="Apple Distribution: …" Scripts/build-and-release.sh 2.0.4 --publish
```

The script builds the frameworks for device and simulator, packages them, signs them,
computes checksums, updates `Package.swift` and publishes a release once you confirm.
A build takes about four minutes.

Without `--publish` the script only builds — the archives end up in `build/`.

### Requirements

- Xcode 27 or later. If `xcode-select -p` points to Command Line Tools or to another
  Xcode, pass the right one via `DEVELOPER_DIR`:
  `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer Scripts/build-and-release.sh …`
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).
- [gh](https://cli.github.com), authenticated for `mc2soft` — only needed with `--publish`.
- An **Apple Distribution** certificate with its private key in the login keychain.

### Code signing

App Store Connect requires binary dependencies that contain SDKs from Apple's
[list of commonly used third-party SDKs](https://developer.apple.com/support/third-party-SDK-requirements/)
to be signed; SnapKit bundled here is on that list. An unsigned build is rejected with
`ITMS-91065: Missing signature`.

The script signs every framework slice and every `.xcframework` with the certificate
given in `CODESIGN_IDENTITY` and verifies each signature; without that variable, or if
the certificate is not in the keychain, the script stops before building.

`CODESIGN_IDENTITY` accepts the full certificate name or its SHA-1 hash. List the
available ones with:

```bash
security find-identity -v -p codesigning
```

Use a certificate of the team that ships the app. A development certificate works for
local builds but is not accepted by App Store Connect. Once a release is published,
keep signing new versions with the same team: Xcode records the signer of each
xcframework in the app and warns when it changes.

To check the signature of a published archive:

```bash
codesign --verify --strict --verbose WebimWidgetBundle.xcframework
codesign -dvv WebimWidgetBundle.xcframework/ios-arm64/WebimWidgetBundle.framework
```

## Licenses

The repository's own code is under [MIT](LICENSE). Licenses of the projects bundled
into the binaries (MIT and BSD-3-Clause) are collected in
[THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
