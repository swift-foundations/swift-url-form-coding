// swift-tools-version: 6.3.3

import PackageDescription

extension String {
    static let urlFormCoding: Self = "URLFormCoding"
}

extension String { var tests: Self { self + " Tests" } }

extension Target.Dependency {
    static var urlFormCoding: Self { .target(name: .urlFormCoding) }
    static var htmlFormCoder: Self {
        .product(name: "HTML Form Coder", package: "swift-html-form-coder")
    }
    static var htmlFormCoderCodable: Self {
        .product(name: "HTML Form Coder Codable", package: "swift-html-form-coder")
    }
    static var htmlStandard: Self {
        .product(name: "HTML Standard", package: "swift-html-standard")
    }
}

let package = Package(
    name: "swift-url-form-coding",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: .urlFormCoding, targets: [.urlFormCoding])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-html-form-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-standards/swift-html-standard.git", branch: "main")
    ],
    targets: [
        .target(
            name: .urlFormCoding,
            dependencies: [
                .htmlFormCoder,
                .htmlFormCoderCodable,
                .htmlStandard,
            ]
        ),
        .testTarget(
            name: .urlFormCoding.tests,
            dependencies: [
                .urlFormCoding,
                .htmlStandard,
            ]
        )
    ]
)

for target in package.targets {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
