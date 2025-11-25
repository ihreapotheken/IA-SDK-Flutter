#!/bin/bash

# Deploys a client package using the Github Source Control.
#
# Usage:
#
# sh ./scripts/deploy-client.sh

# Declare script and project paths.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_DIR="$SCRIPT_DIR/.."

# Setup the environment variables.
source $SCRIPT_DIR/dev-env-setup.sh

# Change current working directory.
cd "$PROJECT_DIR" 

# Add latest updates to source control.
git add android/ ios/ example/ lib/ README.md pubspec.yaml .env
git commit -m "Flutter library deploy version $APP_SDK_VERSION"
git push

# Tag the current release.
git tag "$APP_SDK_BUILD_VERSION-$APP_SDK_BUILD_NUMBER"

# Push the tags, enabling clients to fetch the dependency using the pubspec `ref` field.
git push --tags