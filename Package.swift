// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "KWDrawerController",
    products: [
        .library(name: "KWDrawerController", targets: ["KWDrawerController"])
    ],
    targets: [
        .target(
            name: "KWDrawerController",
            path: "KWDrawerController/DrawerController"
        )
    ]
)

