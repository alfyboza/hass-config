#!/bin/bash
set -e

config="${CONFIG_FILE:-$HOME/.hass-config}"
me="$(basename $0)"

info () {
  echo -e "$(tput setaf 4)$(tput bold)$@$(tput sgr0)"
}

success () {
  echo -e "$(tput setaf 2)$@$(tput sgr0)"
}

# Check for path to copy files to
if [[ $# -ne 1 && ! -f "$config" ]]; then
  echo "$me: specify path to Home Assistant" >&2
  exit 1
elif [[ -n "$1" ]]; then
  hass_path="$1"
else
  hass_path="$(cat $config)"
fi

# Ensure path is a directory
if [[ ! -d "$hass_path" ]]; then
  echo "$me: path to Home Assistant '$hass_path' is invalid" >&2
  exit 1
fi

# Get absolute path to directory with YAML files
pushd "$(dirname $0)/../homeassistant" > /dev/null
source="$(pwd -P)/"
popd > /dev/null

# Perform copy of files via rsync
target="${hass_path%/}"
info "rsync --archive --verbose $source $target"
rsync --archive --verbose "$source" "$target"

# If config file does not exist, create it
if [[ ! -f "$config" ]]; then
  echo "$target" > "$config"
fi

success 'Done!'
