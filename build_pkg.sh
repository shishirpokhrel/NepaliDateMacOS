#!/bin/bash
set -e

APP_NAME="NepaliDate"
SCHEME="NepaliDate"
BUILD_DIR="build_artifacts_clean"
PKG_NAME="NepaliDate.pkg"

echo "Cleaning previous build..."
rm -rf "$BUILD_DIR"
rm -f "$PKG_NAME"

echo "Cleaning extended attributes (skipping .git and build artifacts)..."
find . -type f -not -path "./.git/*" -not -path "./build_artifacts*" -exec xattr -c {} +

echo "Building $APP_NAME..."
# Build for Release
xcodebuild -scheme "$SCHEME" \
    -destination 'platform=macOS,arch=arm64' \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
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
# Create the package
pkgbuild --install-location /Applications --component "$APP_PATH" "$PKG_NAME"

echo "Copying App to Desktop for easy access..."
rm -rf "/Users/shishirpokhrel/Desktop/$APP_NAME.app"
cp -R "$APP_PATH" "/Users/shishirpokhrel/Desktop/$APP_NAME.app"

echo "------------------------------------------------"
echo "Package created successfully: $PWD/$PKG_NAME"
echo "App copied to Desktop: /Users/shishirpokhrel/Desktop/$APP_NAME.app"
echo "------------------------------------------------"

echo "Launching the app from Desktop..."
open "/Users/shishirpokhrel/Desktop/$APP_NAME.app"
