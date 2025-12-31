// swift-tools-version:6.1

import PackageDescription

extension String {
    static let urlFormCoding: Self = "URLFormCoding"
}

extension String { var tests: Self { self + " Tests" } }

extension Target.Dependency {
    static var urlFormCoding: Self { .target(name: .urlFormCoding) }
    static var rfc2388: Self { .product(name: "RFC 2388", package: "swift-rfc-2388") }
    static var whatwgUrlEncoding: Self { .product(name: "WHATWG URL Encoding", package: "swift-whatwg-url-encoding") }
}

let package = Package(
    name: "swift-url-form-coding",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: .urlFormCoding, targets: [.urlFormCoding])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-rfc-2388", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-whatwg-url-encoding.git", from: "0.1.0")
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
