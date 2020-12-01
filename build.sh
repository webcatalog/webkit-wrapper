#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# https://liamnichols.eu/2020/08/01/building-swift-packages-as-a-universal-binary.html
# check version
swift build --version
# build
swift build -c release --arch arm64 --arch x86_64
# validate
lipo -info .build/apple/Products/Release/WebkitWrapper