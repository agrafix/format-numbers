#!/bin/bash

set -e

HACKAGESERVER=hackage.haskell.org

if [ -z "$HACKAGE_KEY" ]; then
    echo "Required environment variable HACKAGE_KEY is not set."
    exit 1
fi

stack sdist
pkgName=$(grep "^name:" package.yaml | awk '{ print $2 }')
vers=$(grep "^version:" package.yaml | awk '{ print $2 }')
distPath=$(stack path | grep "dist-dir" | awk '{ print $2 }')

tarLoc="${distPath}/${pkgName}-${vers}.tar.gz"

if [ ! -f "$tarLoc" ]; then
    echo "Missing $tarLoc"
    exit 1
fi

echo "Will upload and publish $pkgName in version $vers"
targetUrl="https://${HACKAGESERVER}/packages/"
echo "Target url: $targetUrl"

curl \
    -X POST \
    -H "Accept: text/plain" \
    -H "Authorization: X-ApiKey ${HACKAGE_KEY}" \
    -F "package=@${tarLoc}" \
    "$targetUrl"
