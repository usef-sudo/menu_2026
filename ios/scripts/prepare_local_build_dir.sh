#!/bin/bash
# Flutter writes App.framework / Flutter.framework under ./build, which lives on
# iCloud Desktop. File Provider tags those binaries and codesign fails with
# "resource fork, Finder information, or similar detritus not allowed".
# Point ./build at a local cache so Android Studio / Xcode can sign simulator builds.
set -euo pipefail

CACHE="${HOME}/Library/Caches/menu_2026_flutter_build"
mkdir -p "${CACHE}"
xattr -w com.apple.fileprovider.ignore#P 1 "${CACHE}" 2>/dev/null || true
xattr -cr "${CACHE}" 2>/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BUILD_LINK="${PROJECT_ROOT}/build"

FORCE="${1:-}"

if [ -L "${BUILD_LINK}" ]; then
  current="$(readlink "${BUILD_LINK}")"
  if [ "${current}" = "${CACHE}" ] || [ "${current}" = "${CACHE}/" ]; then
    exit 0
  fi
  rm -f "${BUILD_LINK}"
elif [ -e "${BUILD_LINK}" ]; then
  if [ "${FORCE}" = "--replace" ]; then
    rm -rf "${BUILD_LINK}"
  else
    # Xcode may already be writing here; don't delete a live build directory.
    xattr -w com.apple.fileprovider.ignore#P 1 "${BUILD_LINK}" 2>/dev/null || true
    xattr -cr "${BUILD_LINK}" 2>/dev/null || true
    exit 0
  fi
fi

ln -s "${CACHE}" "${BUILD_LINK}"
