#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

readonly updateLevel="$(tr '[:upper:]' '[:lower:]' <<< "${1}")"
if [[ ! "${updateLevel}" =~ ^major|minor|patch$ ]]; then
  echo "invalid parameter: ${updateLevel}"
  exit 1
fi

# Read the latest tag. If there are none, start from v0.0.0.
readonly currentTag="$(git describe --tags --abbrev=0 2>/dev/null)"
readonly latestTag="${currentTag:-"v0.0.0"}"

# Remove the 'v' prefix for version calculation.
readonly version=${latestTag#v}
readonly currentMajor="$(cut -d'.' -f1 <<< "${version}")"
readonly currentMinor="$(cut -d'.' -f2 <<< "${version}")"
readonly currentPatch="$(cut -d'.' -f3 <<< "${version}")"

declare major minor patch
case "${updateLevel}" in
    "major")
        major="$((currentMajor + 1))"
        minor="0"
        patch="0"
        ;;
    "minor")
        major="${currentMajor}"
        minor="$((currentMinor + 1))"
        patch="0"
        ;;
    "patch")
        major="${currentMajor}"
        minor="${currentMinor}"
        patch="$((currentPatch + 1))"
        ;;
    *)
        echo "invalid state none of 'major', 'minor', or 'patch' : ${updateLevel}"
        exit 1
esac

echo "v${major}.${minor}.${patch}"
