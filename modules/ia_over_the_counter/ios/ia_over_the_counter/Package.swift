// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

func loadEnv() -> [String: String] {
    let packageRoot = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let url = URL(fileURLWithPath: "\(packageRoot)/../../../../.env")
    guard let text = try? String(contentsOf: url, encoding: .utf8) else { return [:] }
    var splitText = text.split(whereSeparator: \.isNewline)
    splitText.removeAll(where: { it in it.isEmpty || it.starts(with: "#") })
    return
        splitText
        .map { $0.split(separator: "=", maxSplits: 1).map(String.init) }
        .reduce(into: [:]) { dict, pair in
            if pair.count == 2 { dict[pair[0]] = pair[1] }
        }
}

let env: [String: String] = loadEnv()

guard let appSdkVersionId = env["IOS_APPSDK_VERSION"] else {
    fatalError("No IOS_APPSDK_VERSION provided from .env file.")
}

func parseVersion(_ versionId: String) -> Version {
    let cleaned = versionId.replacingOccurrences(of: "\"", with: "")
    let parts = cleaned.split(separator: ".", maxSplits: 2).map(String.init)
    let major = Int(parts[0]) ?? 0
    let minor = parts.count > 1 ? Int(parts[1]) ?? 0 : 0
    var patch = 0
    var prereleaseIdentifiers: [String] = []
    if parts.count > 2 {
        let patchAndPre = parts[2]
        if let dashIndex = patchAndPre.firstIndex(of: "-") {
            let patchPart = patchAndPre[..<dashIndex]
            let prereleasePart = patchAndPre[patchAndPre.index(after: dashIndex)...]

            patch = Int(patchPart) ?? 0
            prereleaseIdentifiers = prereleasePart.split(separator: ".").map(String.init)
        } else {
            patch = Int(patchAndPre) ?? 0
        }
    }
    return Version(
        major,
        minor,
        patch,
        prereleaseIdentifiers: prereleaseIdentifiers
    )
}

let appSdkVersion = parseVersion(appSdkVersionId)

let package = Package(
    name: "ia_over_the_counter",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "ia-over-the-counter", targets: ["ia_over_the_counter"])
    ],
    dependencies: [
	    .package(url: "https://github.com/ihreapotheken/IA-SDK-iOS", exact: appSdkVersion)
    ],
    targets: [
        .target(
            name: "ia_over_the_counter",
            dependencies: [
                .product(name: "IAIntegrations", package: "IA-SDK-iOS"),
                .product(name: "IAOverTheCounter", package: "IA-SDK-iOS"),
            ],
            resources: [
                // If your plugin requires a privacy manifest, for example if it uses any required
                // reason APIs, update the PrivacyInfo.xcprivacy file to describe your plugin's
                // privacy impact, and then uncomment these lines. For more information, see
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),

                // If you have other resources that need to be bundled with your plugin, refer to
                // the following instructions to add them:
                // https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package
            ]
        )
    ]
)
