// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "KWDrawController",
    products: [
        .library(name: "KWDrawController", targets: ["KWDrawController"])
    ],
    targets: [
        .target(
            name: "KWDrawController",
            path: "KWDrawController/DrawController"
        )
    ]
)

