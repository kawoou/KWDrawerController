// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "KWDrawerController",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "KWDrawerController", targets: ["KWDrawerController"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact( "5.0.0"))
    ],
    targets: [
        .target(
            name: "KWDrawerController",
            dependencies: [ "RxSwift", "RxCocoa" ],
            path: "DrawerController"
        )
    ]
)
