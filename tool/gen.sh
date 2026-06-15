#!/usr/bin/env sh
# Code generation for klik_app.
#
# IMPORTANT: do NOT use `dart run build_runner build` in this project — the
# objective_c native build hook (pulled in by flutter_secure_storage on Apple
# platforms) breaks build_runner's AOT step. Use this script instead.
#
# Usage:  sh tool/gen.sh     (run from the project root)
set -e

FLUTTERGEN="$HOME/.pub-cache/bin/fluttergen"

if [ ! -x "$FLUTTERGEN" ]; then
  echo "fluttergen not found — activating it once..."
  dart pub global activate flutter_gen
fi

echo "Generating assets & fonts (lib/gen/)..."
"$FLUTTERGEN" -c pubspec.yaml

echo "Done. (Localization is JSON-based — edit assets/lang/*.json + LocaleKeys, no codegen needed.)"
