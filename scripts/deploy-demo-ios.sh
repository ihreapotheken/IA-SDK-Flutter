#!/bin/bash

# Deploys the iOS demo app using the TestFlight service.
#
# Usage:
#
# sh ./scripts/deploy-demo-ios.sh

# Declare script and project paths.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_DIR="$SCRIPT_DIR/.."

# Setup the environment variables.
source $SCRIPT_DIR/dev-env-setup.sh

# Change current working directory.
cd "$PROJECT_DIR/example" 

# Clean any temporary files.
flutter clean
rm -rf ios/.symlinks ios/Pods ios/Podfile.lock

# Enable SPM integration.
flutter config --enable-swift-package-manager

# Build the release archive file.
flutter build ipa --release

# Deploy the file to the TestFlight service.
xcodebuild -exportArchive \
  -archivePath $PROJECT_DIR/example/build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist $PROJECT_DIR/example/ios/ExportOptions.plist \
  -exportPath $PROJECT_DIR/example/build/ios/archive/

# Display an informative message.
set -a # Automatically export all variables
source $PROJECT_DIR/.env
set +a
sh $SCRIPT_DIR/info.sh \
    "iOS Flutter demo app version $APP_SDK_VERSION has been deployed with AppSDK version $IOS_APPSDK_VERSION."