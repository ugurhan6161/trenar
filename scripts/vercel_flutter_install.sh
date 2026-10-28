#!/usr/bin/env bash
set -euo pipefail

flutter_version="3.47.2"
sdk_dir="${HOME}/.cache/trenar-flutter/${flutter_version}"
archive="${TMPDIR:-/tmp}/flutter_linux_${flutter_version}-stable.tar.xz"

if [[ ! -x "${sdk_dir}/bin/flutter" ]]; then
  mkdir -p "${sdk_dir}"
  curl --fail --location --retry 3 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz" \
    --output "${archive}"
  tar -xJf "${archive}" --strip-components=1 -C "${sdk_dir}"
  rm -f "${archive}"
fi

git config --global --add safe.directory "${sdk_dir}"

export PATH="${sdk_dir}/bin:${PATH}"
flutter --version

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"
flutter pub get
