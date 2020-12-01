// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "WebkitWrapper",
  platforms: [
    .macOS(.v10_10),
  ],
  products: [
    .executable(name: "WebkitWrapper", targets: ["WebkitWrapper"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "WebkitWrapper",
      dependencies: []
    ),
  ]
)
