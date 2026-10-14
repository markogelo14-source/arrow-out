#!/bin/sh
# Copies the app's model files in and runs the tests. Works on a Mac (Xcode installed) or Linux with Swift.
set -e
cd "$(dirname "$0")"
cp ../Arrowly/Model/*.swift Sources/ArrowlyCore/
swift test
