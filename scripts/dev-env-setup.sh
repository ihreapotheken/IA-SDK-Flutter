#!/usr/bin/env bash

# Sets up the development environment for script execution management.
#
# Usage:
#
# source ./scripts/dev-env-setup.sh

# Export ENV variables for build versioning.
if [[ -z "$APP_SDK_VERSION" || $0 == "dev-env-setup.sh" ]]; then
  # Define the library version number.
  export APP_SDK_BUILD_VERSION="$(date +%Y.%m.%d)"
  echo "APP_SDK_BUILD_VERSION $APP_SDK_BUILD_VERSION"
  # Define the build version number.
  export APP_SDK_BUILD_NUMBER="$(date +'%H*60+%M' | bc)"
  echo "APP_SDK_BUILD_NUMBER $APP_SDK_BUILD_NUMBER"
  # Export library and app version numbers.
  export APP_SDK_VERSION="$APP_SDK_BUILD_VERSION.$APP_SDK_BUILD_NUMBER"
  echo "APP_SDK_VERSION $APP_SDK_VERSION"
fi

# ia.de server environment the demo apps are built against. Matches the
# `IaSdkConfigurationServerEnvironment` value names, and defaults to `staging` just
# like the `iaServerEnv` dart-define read by `ExampleAppConfig`.
#
# Override per deploy, e.g. IA_SERVER_ENV=production sh ./scripts/deploy-demo.sh
export IA_SERVER_ENV="${IA_SERVER_ENV:-staging}"
echo "IA_SERVER_ENV $IA_SERVER_ENV"

# Short environment tag appended to the demo app launcher label, so testers can tell
# which backend a Firebase App Distribution / TestFlight build talks to.
case "$IA_SERVER_ENV" in
  production) export IA_ENV_LABEL="PROD" ;;
  development) export IA_ENV_LABEL="DEV" ;;
  *) export IA_ENV_LABEL="QA" ;;
esac
echo "IA_ENV_LABEL $IA_ENV_LABEL"

# Example app flavor to build, one of the values in example/lib/flavor.dart. Every flavor is the same app to Firebase
# App Distribution and TestFlight, with the same signing, so any of them is delivered like the demo.
#
# Override per deploy, e.g. IA_FLAVOR=singleEntryPoint sh ./scripts/deploy-demo.sh
export IA_FLAVOR="${IA_FLAVOR:-demo}"
echo "IA_FLAVOR $IA_FLAVOR"
