#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Extract the Flutter version from .fvmrc file
FLUTTER_VERSION=$(cat .fvmrc | grep "flutter" | cut -d '"' -f 4)

# Clone the Flutter repository with the specified version
git clone https://github.com/flutter/flutter.git --depth 1 -b $FLUTTER_VERSION $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Print the Flutter version
flutter --version

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

flutter build ios --config-only --dart-define=FLAVOR=prod --dart-define=admobIdIos="${admobIdIos}"

exit 0