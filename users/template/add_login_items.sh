#! /usr/bin/env bash

set -euo pipefail

# Helper function to add login item if not exists
add_login_item() {
  local app_path="$1"
  local app_name
  app_name=$(basename "$app_path" .app)

  if [ false = "$(osascript -e "tell application \"System Events\" to exists login item \"$app_name\"")" ] ; then
    echo "adding $app_name to Login Items"
    osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$app_path\", hidden:false}" >/dev/null
  fi
}

apps=(
  "/Applications/Flux.app"
  "/Applications/NordVPN.app"
  "/Applications/Rectangle.app"
  "/Applications/Raycast.app"
)

for app in "${apps[@]}"; do
  add_login_item "$app"
done

# Check if login item exists
login_items=$(osascript -e 'tell application "System Events" to get the name of every login item')
echo "Login Items: ${login_items[*]}"
