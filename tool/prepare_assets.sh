#!/usr/bin/env bash
set -euo pipefail
flutter precache --web
task_flutter_root="$(cd "$(dirname "$(command -v flutter)")/.." && pwd)"
mkdir -p assets/fonts web/icons
cp "$task_flutter_root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf" assets/fonts/Roboto-Regular.ttf
curl --fail --location --retry 3 --max-time 120 \
  https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm \
  --output web/sqlite3.wasm
python3 tool/make_icons.py
flutter pub get
dart compile js -O4 -o web/drift_worker.dart.js web/drift_worker.dart
