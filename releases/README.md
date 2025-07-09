# MyGainz Releases

This directory contains pre-built APK files for MyGainz releases.

## 📱 Current Release: v2.0.1

- **MyGainz-v2.0.1-release.apk** (55.2MB) - Production ready APK

> **Note**: Debug APK is not included due to GitHub's 100MB file size limit (debug APK is ~203MB).  
> Debug APKs can be built locally using the build script.

## 🏗️ Build Process

### Automated Build Script
Use the provided build script to generate APKs for new releases:

```bash
# From the project root directory
./build_release.sh
```

## 🚀 Release Workflow

1. **Update Version**: Modify version in mygainz/pubspec.yaml
2. **Update Changelog**: Add new version entry to mygainz/CHANGELOG.md
3. **Build APKs**: Run ./build_release.sh or build manually
4. **Commit Release APK**: git add releases/MyGainz-v[VERSION]-release.apk && git commit -m "Add v[VERSION] release APK"
5. **Push to trigger release**: git push origin main
6. **GitHub Actions**: Automatically creates release with APK download

## 🔧 Benefits of Pre-built APKs

- ✅ **No Firebase Config Issues**: APKs built locally with proper Firebase setup
- ✅ **Faster CI/CD**: No need to build in GitHub Actions (~5x faster)
- ✅ **Secure**: Firebase keys never exposed in CI environment
- ✅ **Reliable**: Consistent builds from your development environment
- ✅ **Quality Control**: You test the exact APKs that get released

## 📝 GitHub File Size Limits

- **GitHub recommended limit**: 50MB per file
- **GitHub hard limit**: 100MB per file
- **Release APK**: ~55MB (slightly over recommended, but acceptable)
- **Debug APK**: ~203MB (exceeds hard limit, not included in repo)

For debug APKs, users can build locally or request them separately.
