#!/usr/bin/env bash
# Build the native IA SDKs from a chosen branch and point THIS wrapper at those
# local builds, so the example app links the branch's SDK instead of a published
# release. Used by .github/workflows/native-from-branch.yml; also runnable by hand.
#
#   ANDROID_BRANCH=develop IOS_BRANCH=develop PLATFORM=all \
#   DEV_ANDROID_DIR=../IA-SDK-Dev-Android DEV_IOS_DIR=../IA-SDK-dev-ios \
#   bash scripts/ci/build-native.sh
#
# Android: builds every SDK module to ~/.m2 (publishToMavenLocal) at NATIVE_VERSION
#   and pins ANDROID_APPSDK_VERSION in .env — the gradle files already consult
#   mavenLocal() before GitHub Packages, so the local build wins.
# iOS: points the plugin's SwiftPM manifests at the IA-SDK-dev-ios checkout (source
#   build) via scripts/connect-local-spm, so the branch's Swift sources are compiled.
#
# Secrets expected in the environment (see scripts/ci/provision-secrets or the
# workflow): STRAPI_*/CARDLINK_* (Android), IASDK_*/NETRC_* (iOS). Missing values
# make a release/publish Android build fail loudly rather than ship blank creds.
set -euo pipefail
cd "$(dirname "$0")/../.."
WRAPPER="$PWD"

PLATFORM="${PLATFORM:-all}"
DEV_ANDROID_DIR="${DEV_ANDROID_DIR:-$WRAPPER/../IA-SDK-Dev-Android}"
DEV_IOS_DIR="${DEV_IOS_DIR:-$WRAPPER/../IA-SDK-dev-ios}"
NATIVE_VERSION="${NATIVE_VERSION:-$(scripts/ci/native-version.sh)}"
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@17}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"

say() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

# sed -i portability (BSD/macOS vs GNU)
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }

set_env_var() {  # KEY VALUE  — upsert KEY="VALUE" in the wrapper .env
  local key="$1" val="$2" f="$WRAPPER/.env"
  touch "$f"
  if grep -q "^${key}=" "$f"; then sedi -E "s|^${key}=.*|${key}=\"${val}\"|" "$f"
  else echo "${key}=\"${val}\"" >> "$f"; fi
}

build_android() {
  [ -d "$DEV_ANDROID_DIR" ] || { echo "::error::DEV_ANDROID_DIR not found: $DEV_ANDROID_DIR"; exit 1; }
  say "Android: building SDK $NATIVE_VERSION from $(git -C "$DEV_ANDROID_DIR" rev-parse --abbrev-ref HEAD) → mavenLocal"
  sedi -E "s/^versionName=.*/versionName=$NATIVE_VERSION/" "$DEV_ANDROID_DIR/version.props"
  ( cd "$DEV_ANDROID_DIR" && ./gradlew --no-daemon publishToMavenLocal -x :app:assembleRelease )
  set_env_var ANDROID_APPSDK_VERSION "$NATIVE_VERSION"
  say "Android: wrapper pinned to ANDROID_APPSDK_VERSION=$NATIVE_VERSION (from mavenLocal)"
}

build_ios() {
  [ -d "$DEV_IOS_DIR" ] || { echo "::error::DEV_IOS_DIR not found: $DEV_IOS_DIR"; exit 1; }
  # Build (or reuse a cached) staged set of versioned XCFrameworks + local SwiftPM
  # package. Cache is keyed by the dev-ios commit so a second wrapper/run on this
  # runner reuses the build instead of spending ~8 min again.
  local sha stage
  sha="$(git -C "$DEV_IOS_DIR" rev-parse --short HEAD)"
  stage="$HOME/.cache/ia-native/ios/$sha"
  if [ -f "$stage/VERSION" ]; then
    NATIVE_VERSION="$(cat "$stage/VERSION")"
    say "iOS: reusing cached XCFrameworks $NATIVE_VERSION ($sha) at $stage"
  else
    say "iOS: building XCFrameworks $NATIVE_VERSION from $sha"
    DEV_IOS_DIR="$DEV_IOS_DIR" NATIVE_VERSION="$NATIVE_VERSION" STAGE="$stage" \
      bash scripts/ci/stage-ios-sdk.sh
  fi
  # Point the plugin's SwiftPM manifests at the local BINARY package (name "IASDK").
  python3 .claude/skills/connect-local-spm/scripts/ia_local_spm.py apply "$stage/ReleaseRepo"
  set_env_var IOS_APPSDK_VERSION "$NATIVE_VERSION"
  say "iOS: wrapper SwiftPM → local XCFrameworks ($NATIVE_VERSION)"
}

echo "Wrapper:        $WRAPPER"
echo "Platform:       $PLATFORM"
echo "Native version: $NATIVE_VERSION"
case "$PLATFORM" in
  all)     build_android; build_ios ;;
  android) build_android ;;
  ios)     build_ios ;;
  *) echo "::error::PLATFORM must be all|android|ios"; exit 1 ;;
esac
say "Done. Native SDK $NATIVE_VERSION wired into the wrapper."
