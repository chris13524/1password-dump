# 1Password Dump

This is a simple script that will dump all data from a 1Password account into a directory of your choosing.

If you're like me, you don't want your entire set of passwords and other important information being stored in a single location. You can use this script to dump all of this data (possibly on a regular basis) in the event something happens to 1Password.

## Usage

Login to 1Password as usual using `eval $(op signin)`.

Dump your data: `./1password-dump.sh <dump dir>`

## Dependencies

You'll need to have the `jq` utility installed to parse JSON.
