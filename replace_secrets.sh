#!/usr/bin/env bash

set -euo pipefail

function replace_secrets {
  if [ ! -f secret/config.json ]; then
    echo -e "\033[0;31m[replace_secrets.sh] secret/config.json not found!\033[0m"
    exit 1
  fi

  local -a keys=()
  while IFS='' read -r line; do
    keys+=("$line")
  done < <(jq --raw-output 'keys[]' secret/config.json)

  for key in "${keys[@]}"; do
    if [[ "$key" != @@*  ]]; then
      continue
    fi

    value=$(jq --raw-output --arg key "$key" '.[$key]' secret/config.json)
    # Find and replace key with value in all files in the repo
    (grep --recursive --files-with-matches --exclude-dir=secret --exclude=config.schema.json --exclude=README.md --exclude=replace_secrets.sh "$key" "$PWD" || true) | while read -r file; do
      sed -i '' "s|$key|$value|g" "$file" || sed -i "s|$key|$value|g" "$file"
    done
  done

  git diff -G '@@.*@@' -- ':(exclude)replace_secrets.sh' > "${1:-/tmp/replace_secrets.diff}"

  echo "[replace_secrets.sh] Secrets replaced successfully."
}

function main() {
  replace_secrets "$@"
}

main "$@"
