#!/bin/bash

#
# For arm64 only
# Update prebuilt WebView library with com.google.android.webview apk
# Usage : ./extract.sh /path/to/com.google.android.webview.apk
#
# http://www.apkmirror.com/apk/google-inc/android-system-webview/
# Android System WebView (arm + arm64)
#

WEBVIEWVERSION=$(cat version)
if ! apktool d -f -s "$@" 1>/dev/null; then
    echo "Failed to extract with apktool!"
    exit 1
fi
WEBVIEWDIR=$(\ls -d com.google.android.webview* || (echo "Input file is not a WebView apk!" ; exit 1))

NEWWEBVIEWVERSION=$(cat $WEBVIEWDIR/apktool.yml | grep versionName | awk '{print $2}')
if [[ $NEWWEBVIEWVERSION != $WEBVIEWVERSION ]]; then
    echo "Updating current WebView $WEBVIEWVERSION to $NEWWEBVIEWVERSION ..."
    echo $NEWWEBVIEWVERSION > version
    rm -rf libwebviewchromium.so
    mv $WEBVIEWDIR/lib/arm64-v8a/* .
    rm webview.apk
    rm -rf $WEBVIEWDIR
    7z x -otmp "$@" 1>/dev/null
    cd tmp
    rm -rf lib
    7z a -tzip -mx0 ../tmp.zip . 1>/dev/null
    cd ..
    rm -rf tmp
    zipalign -v 4 tmp.zip webview.apk 1>/dev/null
    rm tmp.zip
else
    echo "Input WebView apk is the same version as before."
    echo "Not updating ..."
fi
rm -rf $WEBVIEWDIR
