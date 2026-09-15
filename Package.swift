// swift-tools-version:6.0
// Сгенерировано Scripts/build-and-release.sh — не редактировать вручную.
// WebimMobileWidget 2.0.3
import PackageDescription

let package = Package(
	name: "WebimWidget",
	platforms: [ .iOS(.v18) ],
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
			checksum: "5e2d42d3ddec0087d435db44658e389a4dbdc96286b9dd975fcdc9da9fc3d5e8",
		),
		.binaryTarget(
			name: "FLAnimatedImage",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/FLAnimatedImage.xcframework.zip",
			checksum: "e1e4072fee0db19f1c970decd7134f9b438e41ad4faf47e756116e8d0b9236ff",
		),
		.binaryTarget(
			name: "Nuke",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/Nuke.xcframework.zip",
			checksum: "209d104567132a1aea383844863be75ac7096720ca9eea4609a9fec02c43b9cb",
		),
		.binaryTarget(
			name: "SQLite",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/SQLite.xcframework.zip",
			checksum: "d7e6b52a886e6f50dde45cc1e6320d2f29e43de18d46cf395c70ffbb3ab37b80",
		),
		.binaryTarget(
			name: "SVGKit",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/SVGKit.xcframework.zip",
			checksum: "0d6f577cd59445e13dba66db304a04be6a8c2fc6fd9edc75614015c65166cbf5",
		),
		.binaryTarget(
			name: "SnapKit",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/SnapKit.xcframework.zip",
			checksum: "5cd5116b0acac75b0e256c069ddf04b56d01e78e5a4afe1c3ce040e060207e07",
		),
		.binaryTarget(
			name: "WebimKeyboard",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/WebimKeyboard.xcframework.zip",
			checksum: "d96a7e7bdc86999f504851cb92de63f230f245dd8d397d1a58a82fbb8c69214d",
		),
		.binaryTarget(
			name: "WebimMobileSDK",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/WebimMobileSDK.xcframework.zip",
			checksum: "e2c428cb133cd83a7b0c3718910dec7dae6768354297847b0655363dbc25c4a9",
		),
		.binaryTarget(
			name: "WebimMobileWidget",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/WebimMobileWidget.xcframework.zip",
			checksum: "b6b0a949d164dc8faffe2c4850c5173c67a47b35d39c5082afe3e464fc1e4296",
		),
		.binaryTarget(
			name: "WebimWidgetBundle",
			url: "https://github.com/mc2soft/webim-widget-xcframework/releases/download/2.0.3/WebimWidgetBundle.xcframework.zip",
			checksum: "d0cc93baeb12cbc0d3d5b649fa23b2ed6af75d1897e06da6965a7921e9f26b01",
		),
	],
)
