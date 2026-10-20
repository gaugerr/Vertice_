#!/usr/bin/env bash
set -euo pipefail
if ! command -v flutter >/dev/null; then
  task_sdk_dir=/tmp/vertice-flutter-3.32.8
  if [ ! -x "$task_sdk_dir/flutter/bin/flutter" ]; then
    mkdir -p "$task_sdk_dir"
    curl --fail --location --retry 3 --max-time 300 \
      https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.8-stable.tar.xz \
      --output "$task_sdk_dir/flutter.tar.xz"
    printf '%s  %s\n' \
      c2c7d75f9be53f10f3fdba2f7e042b2ef0852cc088392b374bcec34c6204ed8c \
      "$task_sdk_dir/flutter.tar.xz" | sha256sum --check --status
    tar --no-same-owner -xf "$task_sdk_dir/flutter.tar.xz" -C "$task_sdk_dir"
    rm "$task_sdk_dir/flutter.tar.xz"
  fi
  export PATH="$task_sdk_dir/flutter/bin:$PATH"
fi
bash tool/prepare_assets.sh
flutter build web --release --wasm --pwa-strategy=none --no-web-resources-cdn
python3 tool/build_service_worker.py
