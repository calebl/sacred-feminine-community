// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "SacredFeminineKit",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(name: "SacredFeminineKit", targets: ["SacredFeminineKit"])
  ],
  targets: [
    .target(name: "SacredFeminineKit"),
    .testTarget(name: "SacredFeminineKitTests", dependencies: ["SacredFeminineKit"]),
  ]
)
