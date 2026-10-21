#!/usr/bin/env bash

# https://dart.dev/tools/dart-doc
#
# Usage:
#
# source ./scripts/dev-env-setup.sh

# Declare script and project paths.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_DIR="$SCRIPT_DIR/.."

# Change current working directory.
cd "$PROJECT_DIR" 

# Generate the documentation to the `doc` directory.
# Remove the previous docs first, `dart doc` doesn't remove pages of removed elements.
rm -rf doc/api
dart doc . || exit 1

# Fix the links of the guides in `docs`, which are included as topics, see `dartdoc_options.yaml`.
dart run scripts/fix_doc_links.dart
