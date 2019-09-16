#!/usr/bin/env bash

set -e

# Create the out directory.
outDir=$1
if [ -z "$outDir" ]; then
  echo "Missing required parameter: output directory"
  exit 1
fi
mkdir -p "$outDir"

# Iterate over each vault.
for vaultId in `op list vaults | jq '.[].uuid' -cr`; do
  # Obtain some information about the vault.
  vault=`op get vault $vaultId`
  vaultName="$(printf '%s' "$vault" | jq '.name' -r)"

  # Figure where to dump the vault to.
  vaultDir="$outDir/$(printf '%q' "$vaultName" | sed 's|\/|_|g')"
  if [ -f "$vaultDir" ]; then
    # If the vault already exists, append its ID to the end to prevent overwriting.
    vaultDir="$vaultDir.$vaultId"
  fi

  # Make a folder for the vault.
  echo "Dumping vault $vaultName to $vaultDir"
  mkdir -p "$vaultDir"

  # Iterate over all items (including trash) inside the vault.
  for itemId in `op list items --include-trash --vault=$vaultId | jq '.[].uuid' -cr`; do
    # Obtain some information about the item.
    item=`op get item $itemId --include-trash`
    itemTitle="$(printf '%s' "$item" | jq '.overview.title' -r)"
    trashed="$(printf '%s' "$item" | jq '.trashed' -r)"
    itemBody="$(printf '%s' "$item" | jq '.')" # just to format it

    # Figure where to dump the item to.
    dot=""
    trashedText=""
    if [ "$trashed" == "Y" ]; then
      dot="."
      trashedText=" (trashed)"
    fi
    itemFile="$vaultDir/$dot$(printf '%q' "$itemTitle" | sed 's|\/|_|g')"
    if [ -f "$itemFile" ]; then
      # If the item file already exists, append its ID to the end to prevent overwriting.
      itemFile="$itemFile.$itemId"
    fi

    # Write the item to a file.
    echo "  Dumping item $itemTitle$trashedText to $itemFile"
    echo "$itemBody" > "$itemFile"
  done
done
