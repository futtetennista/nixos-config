#!/usr/bin/env bash

set -euo pipefail

function replace_secrets {
  if [ ! -f secret-config.json ]; then
    echo -e "\033[0;31m[replace_secrets.sh] secret-config.json not found!\033[0m"
    exit 1
  fi

  local -a keys=()
  while IFS='' read -r line; do
    keys+=("$line")
  done < <(jq --raw-output 'keys[]' secret-config.json)

  for key in "${keys[@]}"; do
    if [ "$key" == "@@env@@" ]; then
      continue
    fi

    value=$(jq --raw-output --arg key "$key" '.[$key]' secret-config.json)
    # Find and replace key with value in all files in the repo
    (grep --recursive --files-with-matches --exclude-dir=secret --exclude=secret-config.json --exclude=replace_secrets.sh "$key" "$PWD" || true) | while read -r file; do
      sed -i '' "s|$key|$value|g" "$file" || sed -i "s|$key|$value|g" "$file"
    done
  done

  git diff -G '@@.*@@' -- ':(exclude)replace_secrets.sh' > "${1:-/tmp/replace_secrets.diff}"

  echo "[replace_secrets.sh] Secrets replaced successfully."
}

function mk_env_file {
  env_path=$(jq --raw-output --arg key '@@env.path@@' '.[$key]' secret-config.json)
  if [ -f "$env_path" ]; then
    rm "$env_path"
  fi

  env=$(jq --raw-output --arg key '@@env@@' '.[$key]' secret-config.json)
  local -a keys=()
  while IFS='' read -r line; do
    keys+=("$line")
  done < <(jq --raw-output 'keys[]' <<<"$env")
  for key in "${keys[@]}"; do
    value=$(jq --raw-output --arg key "$key" '.[$key]' <<<"$env")
    echo "export $key=$value" >> "$env_path"
  done
}

function main() {
  replace_secrets "$@"
  mk_env_file
}

main "$@"
