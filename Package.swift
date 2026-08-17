// swift-tools-version:5.9
// Сгенерировано Scripts/build-and-release.sh — не редактировать вручную.
// WebimMobileWidget 2.0.3
import PackageDescription

let package = Package(
	name: "WebimWidget",
	platforms: [ .iOS(.v13) ],
	products: [
		.library( name: "WebimWidget", targets: [
			"Cosmos",
			"FLAnimatedImage",
			"Nuke",
			"SQLite",
			"SVGKit",
			"SnapKit",
			"WebimKeyboard",
			"WebimMobileSDK",
			"WebimMobileWidget",
			"WebimWidgetBundle",
		] ),
	],
	targets: [
		.binaryTarget(
			name: "Cosmos",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/Cosmos.xcframework.zip",
			checksum: "ad7eb1e966abb3a754c417d97a4bbfac5e55dfed7d8a0efc62a6b01896b9fc6d",
		),
		.binaryTarget(
			name: "FLAnimatedImage",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/FLAnimatedImage.xcframework.zip",
			checksum: "beab7d710a6d338ba8aa9db441fd32b5585b9639296135f5052e03e4616246e3",
		),
		.binaryTarget(
			name: "Nuke",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/Nuke.xcframework.zip",
			checksum: "0783dfdf4b65103356c8b7e2ad8b58e4a3d8e4c9bc59ff0a24409bf9256c40f5",
		),
		.binaryTarget(
			name: "SQLite",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/SQLite.xcframework.zip",
			checksum: "0a736fd39f6a57cedf397ea4ca8a6f2bf5819e4d7120d1626ea02d38ec6248cd",
		),
		.binaryTarget(
			name: "SVGKit",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/SVGKit.xcframework.zip",
			checksum: "654d15be0a4cd7217ef9e2399f39e047b53d1db3db0ee9011ae4271f798ffba2",
		),
		.binaryTarget(
			name: "SnapKit",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/SnapKit.xcframework.zip",
			checksum: "7f9d7a84cce2526d86ad8568a2c51b00983375c39d7107155308ab6f202c70b1",
		),
		.binaryTarget(
			name: "WebimKeyboard",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/WebimKeyboard.xcframework.zip",
			checksum: "dafc0fde3cd8ce7fa7f4659fa6f339531124cb52ebf0aeab64ed9c5bf6235be1",
		),
		.binaryTarget(
			name: "WebimMobileSDK",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/WebimMobileSDK.xcframework.zip",
			checksum: "ed9a649618287a6c4d472b001b9e1dd7e737332e39be633c41583a4eac88290d",
		),
		.binaryTarget(
			name: "WebimMobileWidget",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/WebimMobileWidget.xcframework.zip",
			checksum: "758fe4d04a3fd3b52b85e1d6f9bbcdeb94dd547f0b7434dca6d01564cb69767f",
		),
		.binaryTarget(
			name: "WebimWidgetBundle",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/WebimWidgetBundle.xcframework.zip",
			checksum: "aeaedc3782eb2dc7c7fc28f7d5a9c18aaac5f789c31d47f2fd31b655e63f1879",
		),
	],
)
