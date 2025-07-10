#!/bin/bash

# MyGainz Release Build Script
# This script builds release and debug APKs and prepares them for GitHub release

set -e  # Exit on any error

echo "🏗️ MyGainz Release Build Script"
echo "================================"

# Change to the Flutter project directory
cd mygainz

# Get the version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
echo "📦 Building version: $VERSION"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build release APK
echo "🔨 Building release APK..."
flutter build apk --release


# Create releases directory if it doesn't exist
mkdir -p ../releases

# Copy APKs to releases directory with version naming
echo "📋 Copying APKs to releases directory..."
cp build/app/outputs/flutter-apk/app-release.apk "../releases/MyGainz-v${VERSION}-release.apk"

# Show file sizes
echo "✅ Build completed successfully!"
echo ""
echo "📱 Generated APKs:"
ls -lh "../releases/MyGainz-v${VERSION}"*.apk

echo ""
echo "🚀 Ready for release!"
echo "   1. Commit the APKs: git add releases/ && git commit -m 'Add v${VERSION} APKs'"
echo "   2. Push to trigger release: git push origin main"
echo "   3. GitHub Actions will create the release automatically"
