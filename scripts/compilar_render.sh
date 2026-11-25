#!/usr/bin/env bash
set -euo pipefail

versao_flutter="3.50.1"
pasta_flutter="$HOME/flutter-$versao_flutter"

if [ ! -x "$pasta_flutter/bin/flutter" ]; then

  rm -rf "$pasta_flutter"
  git clone --quiet --depth 1 --branch "$versao_flutter" https://github.com/flutter/flutter.git "$pasta_flutter"

fi

export PATH="$pasta_flutter/bin:$PATH"

flutter --suppress-analytics --version
flutter --suppress-analytics pub get
flutter --suppress-analytics build web --release --no-web-resources-cdn --no-wasm-dry-run --dart-define="ENDERECO_SERVIDOR=$ENDERECO_SERVIDOR"
