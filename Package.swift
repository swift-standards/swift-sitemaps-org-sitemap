// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-sitemaps-org-sitemap",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Sitemap", targets: ["Sitemap"]),
        .library(name: "Sitemap Language Alternates", targets: ["Sitemap Language Alternates"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-w3c/swift-w3c-xml.git", branch: "main"),
        .package(url: "https://github.com/swift-iso/swift-iso-8601.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3986.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-bcp-47.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Sitemap",
            dependencies: [
                .product(name: "W3C XML", package: "swift-w3c-xml"),
                .product(name: "ISO 8601", package: "swift-iso-8601"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
            ]
        ),
        .target(
            name: "Sitemap Language Alternates",
            dependencies: [
                .target(name: "Sitemap"),
                .product(name: "BCP 47", package: "swift-bcp-47"),
            ]
        ),
        .testTarget(
            name: "Sitemap Tests",
            dependencies: [
                .target(name: "Sitemap")
            ]
        ),
        .testTarget(
            name: "Sitemap Language Alternates Tests",
            dependencies: [
                .target(name: "Sitemap Language Alternates")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
