// swift-tools-version: 6.3.3

import PackageDescription

extension String {
    static let urlFormCoding: Self = "URLFormCoding"
}

extension String { var tests: Self { self + " Tests" } }

extension Target.Dependency {
    static var urlFormCoding: Self { .target(name: .urlFormCoding) }
    static var rfc2388: Self { .product(name: "RFC 2388", package: "swift-rfc-2388") }
    static var whatwgUrlEncoding: Self { .product(name: "WHATWG Form URL Encoded", package: "swift-whatwg-url") }
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
        .package(url: "https://github.com/swift-ietf/swift-rfc-2388.git", branch: "main"),
        .package(url: "https://github.com/swift-whatwg/swift-whatwg-url.git", branch: "main")
    ],
    targets: [
        .target(
            name: .urlFormCoding,
            dependencies: [
                .rfc2388,
                .whatwgUrlEncoding
            ]
        ),
        .testTarget(
            name: .urlFormCoding.tests,
            dependencies: [
                .urlFormCoding
            ]
        )
    ]
)

for target in package.targets {
    target.swiftSettings?.append(
        contentsOf: [
            .enableUpcomingFeature("MemberImportVisibility")
        ]
    )
}
