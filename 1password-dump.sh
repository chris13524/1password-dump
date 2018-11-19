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
for vault in `op list vaults | jq ".[]" -c`; do
  # Obtain some information about the vault.
  vaultId=`echo $vault | jq ".uuid" -r`
  vaultName=`echo $vault | jq ".name" -r`

  # Figure where to dump the vault to.
  vaultDir="$outDir/$(echo $vaultName | sed 's/\//\\\//g')"
  if [ -f "$vaultDir" ]; then
    # If the vault already exists, append its ID to the end to prevent overwriting.
    vaultDir="$vaultDir.$vaultId"
  fi

  # Make a folder for the vault.
  echo "Dumping vault $vaultName to $vaultDir"
  mkdir -p "$vaultDir"

  # Iterate over all items (including trash) inside the vault.
  for itemId in `op list items --include-trash | jq ".[].uuid" -cr`; do
    # Obtain some information about the item.
    item=`op get item $itemId --include-trash`
    itemTitle=`echo $item | jq ".overview.title" -r`
    trashed=`echo $item | jq ".trashed" -r`
    itemBody=`echo $item | jq "."` # just to format it

    # Figure where to dump the item to.
    dot=""
    trashedText=""
    if [ "$trashed" == "Y" ]; then
      dot="."
      trashedText=" (trashed)"
    fi
    itemFile="$vaultDir/$dot$(echo $itemTitle | sed 's/\//\\\//g')"
    if [ -f "$itemFile" ]; then
      # If the item file already exists, append its ID to the end to prevent overwriting.
      itemFile="$itemFile.$itemId"
    fi

    # Write the item to a file.
    echo "  Dumping item $itemTitle$trashedText to $itemFile"
    echo "$itemBody" > "$itemFile"
  done
done
