#!/usr/bin/env bash

set -e

outDir=$1
if [ -z "$outDir" ]; then
  echo "Missing required parameter: output directory"
  exit 1
fi

mkdir -p "$outDir"

for vault in `op list vaults | jq ".[]" -c`; do
  vaultId=`echo $vault | jq ".uuid" -r`
  vaultName=`echo $vault | jq ".name" -r`
  vaultDir="$outDir/$(echo $vaultName | sed 's/\//\\\//g')"
  if [ -f "$vaultDir" ]; then
    vaultDir="$vaultDir.$vaultId"
  fi
  echo "Dumping vault $vaultName to $vaultDir"
  mkdir -p "$vaultDir"
  for itemId in `op list items --include-trash | jq ".[].uuid" -cr`; do
    item=`op get item $itemId --include-trash`
    itemTitle=`echo $item | jq ".overview.title" -r`
    trashed=`echo $item | jq ".trashed" -r`
    itemBody=`echo $item | jq "."` # just to format it
    dot=""
    trashedText=""
    if [ "$trashed" == "Y" ]; then
      dot="."
      trashedText=" (trashed)"
    fi
    itemFile="$vaultDir/$dot$(echo $itemTitle | sed 's/\//\\\//g')"
    if [ -f "$itemFile" ]; then
      itemFile="$itemFile.$itemId"
    fi
    echo "  Dumping item $itemTitle$trashedText to $itemFile"
    echo "$itemBody" > "$itemFile"
  done
done
