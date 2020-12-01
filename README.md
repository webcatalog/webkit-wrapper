# WebKit Wrapper [![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

|macOS|
|---|
|[![GitHub Actions macOS Build Status](https://github.com/webcatalog/webkit-wrapper/workflows/macOS/badge.svg)](https://github.com/webcatalog/webkit-wrapper/actions?query=workflow%3AmacOS)|

Tthe source code of the WebKit Wrapper - the core that powers the WebKit-based apps created with WebCatalog. 

---

## Development
```bash
# clone the project:
git clone https://github.com/webcatalog/webkit-wrapper.git
cd webkit-wrapper
```

```bash
# run development mode
swift run

# build universal binary
# output to .build/apple/Products/Release/WebkitWrapper
./build

# package template app as zip file
yarn
yarn dist
```