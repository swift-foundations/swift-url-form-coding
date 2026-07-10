// swift-tools-version: 6.3.3

import PackageDescription

extension String {
    static let urlFormCoding: Self = "URLFormCoding"
    static let urlFormCodingURLRouting: Self = "URLFormCodingURLRouting"
}

extension String { var tests: Self { self + " Tests" } }

extension Target.Dependency {
    static var urlFormCoding: Self { .target(name: .urlFormCoding) }
    static var urlFormCodingURLRouting: Self { .target(name: .urlFormCodingURLRouting) }
    static var rfc2388: Self { .product(name: "RFC 2388", package: "swift-rfc-2388") }
    static var whatwgUrlEncoding: Self { .product(name: "WHATWG Form URL Encoded", package: "swift-whatwg-url") }
    // Institute fork URL (principal ruling 2026-07-09); pinned to upstream-identical tags
    // (0.6.2 = pointfree release SHA); do NOT use branch:main until the RFC-first rewrite lands via the routing arc.
    static var urlRouting: Self { .product(name: "URLRouting", package: "swift-url-routing") }
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
        .library(name: .urlFormCoding, targets: [.urlFormCoding]),
        .library(name: .urlFormCodingURLRouting, targets: [.urlFormCodingURLRouting])
    ],
    traits: [
        .trait(
            name: "URLRouting",
            description: "URLRouting integration for URLFormCoding"
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-2388.git", branch: "main"),
        .package(url: "https://github.com/swift-whatwg/swift-whatwg-url.git", branch: "main"),
        // Institute fork URL (principal ruling 2026-07-09); pinned to upstream-identical tags
        // (0.6.2 = pointfree release SHA); do NOT use branch:main until the RFC-first rewrite lands via the routing arc.
        // This backs the standalone URLFormCodingURLRouting product only; the URLFormCoding product is unaffected.
        .package(url: "https://github.com/swift-foundations/swift-url-routing.git", from: "0.6.0")
    ],
    targets: [
        .target(
            name: .urlFormCoding,
            dependencies: [
                .rfc2388,
                .whatwgUrlEncoding
            ]
        ),
        // Standalone URLRouting integration. Vends the module `URLFormCodingURLRouting` with an
        // unconditional URLRouting dependency, so consumers use the product WITHOUT enabling the
        // package-level "URLRouting" trait. The trait remains declared only to gate the main
        // target's optional `@_exported import URLRouting` in exports.swift (default off).
        .target(
            name: .urlFormCodingURLRouting,
            dependencies: [
                .urlFormCoding,
                .urlRouting
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
