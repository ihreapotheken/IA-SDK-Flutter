#!/bin/bash

# Deploys the Android demo app using the Firebase App Tester service.
#
# Usage:
#
# sh ./scripts/deploy-demo-android.sh

# Declare script and project paths.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_DIR="$SCRIPT_DIR/.."

# Setup the environment variables.
source $SCRIPT_DIR/dev-env-setup.sh

# Change current working directory.
cd "$PROJECT_DIR/example" 

# Clean any temporary files.
flutter clean

# Build the release APK file. `IA_SERVER_ENV` reaches the launcher label through the
# `app_name` resource declared in example/android/app/build.gradle.kts.
#
# Abort on failure. Without this the upload below runs against a stale or missing APK
# and the script still reports a successful deploy.
flutter build apk --release \
  --build-name="$APP_SDK_BUILD_VERSION" \
  --build-number="$APP_SDK_BUILD_NUMBER" \
  --dart-define=iaServerEnv="$IA_SERVER_ENV" || exit 1

# Deploy the file to the Firebase App Tester service.
cd android
./gradlew appDistributionUploadRelease || exit 1

# Display an informative message.
set -a # Automatically export all variables
source $PROJECT_DIR/.env
set +a
sh $SCRIPT_DIR/info.sh \
    "Android Flutter demo app version $APP_SDK_VERSION has been deployed with AppSDK version $ANDROID_APPSDK_VERSION, targeting the $IA_ENV_LABEL environment."