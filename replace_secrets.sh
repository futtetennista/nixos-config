#!/usr/bin/env bash

set -euo pipefail

if [ ! -f secret/config.json ]; then
  echo -e "\033[0;31m[replace_secrets.sh] secret/config.json not found!\033[0m"
  exit 1
fi

keys=( $(jq --raw-output 'keys[]' secret/config.json) )

for key in "${keys[@]}"; do
  value=$(jq --raw-output --arg key "$key" '.[$key]' secret/config.json)
  # Find and replace key with value in all files in the repo
  (grep --recursive --files-with-matches --exclude-dir=secret "$key" "$PWD" || true) | while read -r file; do
    sed -i '' "s|$key|$value|g" "$file"
  done
done

echo "[replace_secrets.sh] Secrets replaced successfully."
