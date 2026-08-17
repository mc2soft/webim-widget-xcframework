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

## Building a new version

```bash
Scripts/build-and-release.sh 2.0.4 --publish
```

The script builds the frameworks for device and simulator, packages them, computes
checksums, updates `Package.swift` and publishes a release once you confirm.
Requires [xcodegen](https://github.com/yonaskolb/XcodeGen) and
[gh](https://cli.github.com). A build takes about four minutes.

Without `--publish` the script only builds — the archives end up in `build/`.

## Licenses

The repository's own code is under [MIT](LICENSE). Licenses of the projects bundled
into the binaries (MIT and BSD-3-Clause) are collected in
[THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
