#!/usr/bin/env bash
set -euo pipefail

app_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sdk_dir="${HOME}/.cache/trenar-flutter/3.47.2"

if [[ ! -x "${sdk_dir}/bin/flutter" ]]; then
  echo "Flutter SDK is missing. Run the Vercel install command first." >&2
  exit 1
fi

required_variables=(
  FIREBASE_API_KEY
  FIREBASE_AUTH_DOMAIN
  FIREBASE_PROJECT_ID
  FIREBASE_STORAGE_BUCKET
  FIREBASE_MESSAGING_SENDER_ID
  FIREBASE_APP_ID
)

for variable in "${required_variables[@]}"; do
  if [[ -z "${!variable:-}" ]]; then
    echo "Missing required Vercel environment variable: ${variable}" >&2
    exit 1
  fi
done

cd "${app_dir}"
export PATH="${sdk_dir}/bin:${PATH}"
flutter build web --release \
  --target lib/main_production.dart \
  --output build/web \
  --dart-define="FIREBASE_API_KEY=${FIREBASE_API_KEY}" \
  --dart-define="FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN}" \
  --dart-define="FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}" \
  --dart-define="FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET}" \
  --dart-define="FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID}" \
  --dart-define="FIREBASE_APP_ID=${FIREBASE_APP_ID}" \
  --dart-define="FIREBASE_MEASUREMENT_ID=${FIREBASE_MEASUREMENT_ID:-}"
