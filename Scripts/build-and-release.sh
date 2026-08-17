#!/bin/bash
#
# Собирает WebimMobileWidget и все его зависимости в набор xcframework,
# упаковывает их и публикует релизом на GitHub.
#
# Смысл затеи: подключить виджет одной бинарной зависимостью вместо девяти
# внешних SPM-пакетов, которые тянутся из исходников при каждом резолве.
#
# Использование:
#   Scripts/build-and-release.sh              # собрать версию из файла version
#   Scripts/build-and-release.sh 2.0.4        # собрать конкретную версию
#   Scripts/build-and-release.sh --publish    # собрать и выложить релиз
#
# Требуются: xcodegen (brew install xcodegen) и gh для публикации.
#
set -euo pipefail

readonly REPO_URL="https://github.com/webim/webim-mobile-ui-ios"
readonly GITHUB_REPO="mc2soft/webim-widget-xcframework"
readonly CODE_FRAMEWORK="WebimWidgetBundle"   # динамический фреймворк со всем кодом
readonly DEPLOYMENT_TARGET="13.0"

readonly ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
readonly BUILD_DIR="$ROOT/build"
readonly VERSION_FILE="$ROOT/version"

# --- аргументы ------------------------------------------------------------

PUBLISH=no
VERSION=""
for arg in "$@"; do
	case "$arg" in
		--publish) PUBLISH=yes ;;
		-*)        echo "error: неизвестный аргумент: $arg" >&2; exit 1 ;;
		*)         VERSION="$arg" ;;
	esac
done

if [ -z "$VERSION" ]; then
	[ -f "$VERSION_FILE" ] || {
		echo "error: не задана версия. Укажите аргументом или в файле $VERSION_FILE" >&2
		exit 1
	}
	VERSION=$( tr -d '[:space:]' < "$VERSION_FILE" )
fi
[ -n "$VERSION" ] || { echo "error: версия пустая" >&2; exit 1; }

command -v xcodegen > /dev/null || {
	echo "error: не найден xcodegen — установите: brew install xcodegen" >&2; exit 1
}
if [ "$PUBLISH" = yes ]; then
	command -v gh > /dev/null || {
		echo "error: для публикации нужен gh — установите: brew install gh" >&2; exit 1
	}
	if git -C "$ROOT" tag --list | grep -qx "$VERSION"; then
		echo "error: тег $VERSION уже существует — версия уже опубликована" >&2
		exit 1
	fi
fi

echo "==> WebimMobileWidget $VERSION"

WORK=$( mktemp -d )
trap 'rm -rf "$WORK"' EXIT

# --- 1. проект-обёртка ----------------------------------------------------

mkdir -p "$WORK/src/Sources"
cat > "$WORK/src/Sources/Empty.swift" <<'EOF'
// Пустой файл: таргет существует только чтобы слинковать WebimMobileWidget
// и все его зависимости в один динамический фреймворк.
EOF

cat > "$WORK/src/project.yml" <<EOF
name: $CODE_FRAMEWORK
options:
  bundleIdPrefix: com.webimwidget
  createIntermediateGroups: true
packages:
  WebimMobileWidgetPkg:
    url: $REPO_URL
    exactVersion: $VERSION
targets:
  $CODE_FRAMEWORK:
    type: framework
    platform: iOS
    deploymentTarget: "$DEPLOYMENT_TARGET"
    sources:
      - Sources
    dependencies:
      - package: WebimMobileWidgetPkg
        product: WebimMobileWidget
    settings:
      base:
        MACH_O_TYPE: mh_dylib
        SKIP_INSTALL: NO
        DEFINES_MODULE: YES
        GENERATE_INFOPLIST_FILE: YES
        CODE_SIGNING_ALLOWED: NO
        CODE_SIGN_IDENTITY: ""
        PRODUCT_BUNDLE_IDENTIFIER: com.webimwidget.$CODE_FRAMEWORK
EOF

( cd "$WORK/src" && xcodegen generate --spec project.yml --project . --quiet )

# --- 2. сборка под устройство и симулятор ---------------------------------

build() {
	local destination="$1" dd="$2"
	echo "==> Сборка: $destination"
	# BUILD_LIBRARY_FOR_DISTRIBUTION с командной строки применяется и к таргетам
	# SPM-пакетов: каждый модуль выпускает текстовый .swiftinterface, который
	# потребитель перекомпилирует у себя. Без него .swiftmodule был бы привязан
	# к версии компилятора и обновление Xcode ломало бы сборку у потребителей.
	( cd "$WORK/src" && xcodebuild build \
		-project "$CODE_FRAMEWORK.xcodeproj" \
		-scheme "$CODE_FRAMEWORK" \
		-configuration Release \
		-destination "$destination" \
		-derivedDataPath "$dd" \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
		-quiet )
}

build "generic/platform=iOS"           "$WORK/dd-device"
build "generic/platform=iOS Simulator" "$WORK/dd-sim"

# --- 3. сборка .framework -------------------------------------------------

info_plist() {
	cat > "$1/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleDevelopmentRegion</key><string>en</string>
<key>CFBundleExecutable</key><string>$2</string>
<key>CFBundleIdentifier</key><string>com.webimwidget.$2</string>
<key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
<key>CFBundleName</key><string>$2</string>
<key>CFBundlePackageType</key><string>FMWK</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>MinimumOSVersion</key><string>$DEPLOYMENT_TARGET</string>
</dict></plist>
EOF
}

# Xcode отдаёт .swiftmodule и ресурсные бандлы зависимостей в BUILT_PRODUCTS_DIR,
# но не кладёт их в продукт таргета — собираем фреймворки вручную.
assemble_platform() {
	local dd="$1" conf="$2" sdk="$3" slice="$4" triples="$5"
	local products="$dd/Build/Products/$conf"
	local modmaps="$dd/Build/Intermediates.noindex/GeneratedModuleMaps-$sdk"
	local dst="$WORK/frameworks/$slice"
	rm -rf "$dst"; mkdir -p "$dst"

	# бинарник-заглушка для интерфейсных фреймворков
	local stub="$WORK/stub-$slice" objs=() n=0
	rm -rf "$stub"; mkdir -p "$stub"
	echo 'void __webim_widget_stub(void) {}' > "$stub/stub.c"
	local triple
	for triple in $triples; do
		n=$(( n + 1 ))
		xcrun clang -c "$stub/stub.c" -o "$stub/stub-$n.o" \
			-target "$triple" -isysroot "$( xcrun --sdk "$sdk" --show-sdk-path )"
		objs+=( "$stub/stub-$n.o" )
	done
	xcrun libtool -static -o "$stub/libstub.a" "${objs[@]}" 2> /dev/null

	# динамический фреймворк: весь код + ресурсные бандлы всех зависимостей
	local b
	cp -R "$products/$CODE_FRAMEWORK.framework" "$dst/"
	for b in "$products"/*.bundle; do
		[ -e "$b" ] && cp -R "$b" "$dst/$CODE_FRAMEWORK.framework/"
	done

	# Swift-модули: интерфейсный фреймворк на каждый .swiftmodule
	local sm name fw
	for sm in "$products"/*.swiftmodule; do
		[ -e "$sm" ] || continue
		name=$( basename "$sm" .swiftmodule )
		fw="$dst/$name.framework"
		mkdir -p "$fw/Modules"
		cp -R "$sm" "$fw/Modules/"
		cp "$stub/libstub.a" "$fw/$name"
		info_plist "$fw" "$name"
	done

	# ObjC-модули: заголовки + modulemap (умбрелла-путь берём из сгенерированного)
	local mm umbrella hdrs
	for mm in "$modmaps"/*.modulemap; do
		[ -e "$mm" ] || continue
		name=$( basename "$mm" .modulemap )
		if [ -d "$dst/$name.framework" ]; then continue; fi
		umbrella=$( grep -o 'umbrella header "[^"]*"' "$mm" 2> /dev/null \
			| sed 's/umbrella header "//;s/"$//' || true )
		if [ -z "$umbrella" ]; then continue; fi
		hdrs=$( dirname "$umbrella" )
		fw="$dst/$name.framework"
		mkdir -p "$fw/Headers" "$fw/Modules"
		cp "$stub/libstub.a" "$fw/$name"
		cp -RL "$hdrs"/* "$fw/Headers/"          # -L: заголовки бывают симлинками
		cat > "$fw/Modules/module.modulemap" <<EOF
framework module $name {
	umbrella header "$( basename "$umbrella" )"
	export *
	module * { export * }
}
EOF
		info_plist "$fw" "$name"
	done
}

echo "==> Собираю .framework"
assemble_platform "$WORK/dd-device" Release-iphoneos        iphoneos        ios-arm64 \
	"arm64-apple-ios$DEPLOYMENT_TARGET"
assemble_platform "$WORK/dd-sim"    Release-iphonesimulator iphonesimulator ios-arm64_x86_64-simulator \
	"arm64-apple-ios$DEPLOYMENT_TARGET-simulator x86_64-apple-ios$DEPLOYMENT_TARGET-simulator"

# --- 4. xcframework и архивы ----------------------------------------------

echo "==> Собираю xcframework"
rm -rf "$BUILD_DIR"; mkdir -p "$BUILD_DIR"
names=()
for path in "$WORK/frameworks/ios-arm64"/*.framework; do
	name=$( basename "$path" .framework )
	names+=( "$name" )
	xcodebuild -create-xcframework \
		-framework "$WORK/frameworks/ios-arm64/$name.framework" \
		-framework "$WORK/frameworks/ios-arm64_x86_64-simulator/$name.framework" \
		-output "$WORK/$name.xcframework" > /dev/null
	# ditto, а не zip: внутри фреймворков есть симлинки, обычный zip их ломает
	ditto -c -k --sequesterRsrc --keepParent \
		"$WORK/$name.xcframework" "$BUILD_DIR/$name.xcframework.zip"
	echo "    $name ($( du -h "$BUILD_DIR/$name.xcframework.zip" | cut -f1 ))"
done

# --- 5. Package.swift -----------------------------------------------------

# Адреса ассетов релиза предсказуемы, поэтому манифест можно сформировать
# до того, как релиз создан.
asset_url() { echo "https://github.com/$GITHUB_REPO/releases/download/$VERSION/$1.xcframework.zip"; }

echo "==> Генерирую Package.swift"
{
	echo "// swift-tools-version:5.9"
	echo "// Сгенерировано Scripts/build-and-release.sh — не редактировать вручную."
	echo "// WebimMobileWidget $VERSION"
	echo "import PackageDescription"
	echo
	echo "let package = Package("
	echo "	name: \"WebimWidget\","
	echo "	platforms: [ .iOS(.v13) ],"
	echo "	products: ["
	echo "		.library( name: \"WebimWidget\", targets: ["
	for name in "${names[@]}"; do echo "			\"$name\","; done
	echo "		] ),"
	echo "	],"
	echo "	targets: ["
	for name in "${names[@]}"; do
		echo "		.binaryTarget("
		echo "			name: \"$name\","
		echo "			url: \"$( asset_url "$name" )\","
		echo "			checksum: \"$( swift package compute-checksum "$BUILD_DIR/$name.xcframework.zip" )\","
		echo "		),"
	done
	echo "	],"
	echo ")"
} > "$ROOT/Package.swift"

echo "$VERSION" > "$VERSION_FILE"

# --- 6. лицензии зависимостей ---------------------------------------------

# Все вошедшие пакеты распространяются под MIT или BSD: обе лицензии требуют
# приложить копирайт и текст лицензии к бинарной поставке.
echo "==> Собираю лицензии зависимостей"
{
	echo "# Third-party licenses"
	echo
	echo "The binaries released from this repository are built from the projects listed below."
	echo "This file is generated by \`Scripts/build-and-release.sh\` from the sources"
	echo "used to build WebimMobileWidget $VERSION."
	echo
	for dir in "$WORK/dd-device/SourcePackages/checkouts"/*; do
		[ -d "$dir" ] || continue
		pkg=$( basename "$dir" )
		lic=$( find "$dir" -maxdepth 1 -iname "LICENSE*" -o -maxdepth 1 -iname "COPYING*" \
			| head -1 )
		echo "## $pkg"
		echo
		if [ -n "$lic" ]; then
			echo '```'
			cat "$lic"
			echo '```'
		else
			echo "_No license file found in the package repository._"
		fi
		echo
	done
} > "$ROOT/THIRD-PARTY-LICENSES.md"

echo "==> Готово: $( du -sh "$BUILD_DIR" | cut -f1 ) в $BUILD_DIR"

# --- 7. публикация --------------------------------------------------------

if [ "$PUBLISH" != yes ]; then
	echo
	echo "Публикация не запрашивалась. Чтобы выложить релиз: $0 $VERSION --publish"
	exit 0
fi

echo
echo "Будет опубликован релиз $VERSION в $GITHUB_REPO (публичный репозиторий):"
for name in "${names[@]}"; do echo "    $name.xcframework.zip"; done
echo
read -r -p "Продолжить? [y/N] " answer
case "$answer" in
	[yY]) ;;
	*) echo "Отменено."; exit 1 ;;
esac

git -C "$ROOT" add Package.swift version THIRD-PARTY-LICENSES.md
git -C "$ROOT" commit -m "WebimMobileWidget $VERSION"
git -C "$ROOT" tag "$VERSION"
git -C "$ROOT" push origin HEAD
git -C "$ROOT" push origin "$VERSION"

gh release create "$VERSION" \
	--repo "$GITHUB_REPO" \
	--title "WebimMobileWidget $VERSION" \
	--notes "Сборка WebimMobileWidget $VERSION со всеми зависимостями в xcframework." \
	"$BUILD_DIR"/*.xcframework.zip

echo "==> Релиз $VERSION опубликован"
