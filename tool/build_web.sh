#!/usr/bin/env bash
set -euo pipefail
if ! command -v flutter >/dev/null; then
  task_sdk_dir=/tmp/vertice-flutter-3.32.8
  if [ ! -x "$task_sdk_dir/flutter/bin/flutter" ]; then
    mkdir -p "$task_sdk_dir"
    curl --fail --location --retry 3 --max-time 300 \
      https://storage.googleapis.com/flutter_infra_release/flutter/3.32.8/linux/flutter_linux_3.32.8-stable.tar.xz \
      --output "$task_sdk_dir/flutter.tar.xz"
    tar -xf "$task_sdk_dir/flutter.tar.xz" -C "$task_sdk_dir"
    rm "$task_sdk_dir/flutter.tar.xz"
  fi
  export PATH="$task_sdk_dir/flutter/bin:$PATH"
fi
bash tool/prepare_assets.sh
flutter build web --release --pwa-strategy=none --no-web-resources-cdn
python3 tool/build_service_worker.py
