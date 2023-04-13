// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "KWDrawerController",
    products: [
        .library(name: "KWDrawerController", targets: ["KWDrawerController"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .from("5.0.0"))
    ],
    targets: [
        .target(
            name: "KWDrawerController",
            path: "DrawerController"
        )
    ]
)

