#!/bin/bash
set -e

APP_NAME="NepaliDate"
SCHEME="NepaliDate"
BUILD_DIR="build_artifacts_clean"
PKG_NAME="NepaliDate.pkg"
APP_COPY_DIR="$PWD/dist"
SCRIPTS_DIR="$PWD/scripts"

echo "Cleaning previous build..."
rm -rf "$BUILD_DIR"
rm -f "$PKG_NAME"

echo "Cleaning extended attributes (skipping .git and build artifacts)..."
find . -type f -not -path "./.git/*" -not -path "./build_artifacts*" -exec xattr -c {} +

echo "Building $APP_NAME..."
xcodebuild -scheme "$SCHEME" \
    -destination 'generic/platform=macOS' \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    SDKROOT=macosx \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    build

APP_PATH="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH"
    exit 1
fi

echo "Configuring Info.plist..."
plutil -replace LSUIElement -bool YES "$APP_PATH/Contents/Info.plist"

echo "Cleaning built app attributes and signing ad-hoc..."
find "$APP_PATH" -exec xattr -c {} +
codesign --force --deep --sign - "$APP_PATH"
echo "Creating Package..."
pkgbuild --install-location /Applications --component "$APP_PATH" --scripts "$SCRIPTS_DIR" "$PKG_NAME"

echo "Copying App to dist for easy access..."
rm -rf "$APP_COPY_DIR"
mkdir -p "$APP_COPY_DIR"
cp -R "$APP_PATH" "$APP_COPY_DIR/$APP_NAME.app"

echo "------------------------------------------------"
echo "Package created successfully: $PWD/$PKG_NAME"
echo "App copied to: $APP_COPY_DIR/$APP_NAME.app"
echo "------------------------------------------------"
