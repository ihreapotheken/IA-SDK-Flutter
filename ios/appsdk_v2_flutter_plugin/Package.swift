// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

func loadEnv() -> [String: String] {
    let packageRoot = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let url = URL(fileURLWithPath: "\(packageRoot)/../../.env")
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
    let parts =
    versionId
        .replacingOccurrences(of: "\"", with: "")
        .split(separator: ".")
        .map {
            String($0)
        }
    let hasPatch = parts.count > 2
    let patchId = hasPatch ? parts[2] : nil
    let hasPrereleaseId = patchId?.contains("-") == true
    let prereleaseIdentifiers =
    hasPrereleaseId ? [String(patchId!.split(separator: "-").last!)] : nil
    return Version(
        Int(parts[0])!,
        parts.count > 1 ? Int(parts[1])! : 0,
        parts.count > 2
        ? hasPrereleaseId
        ? Int(parts[2].split(separator: "-").first ?? "0")! : Int(parts[2])!
        : 0,
        prereleaseIdentifiers: prereleaseIdentifiers ?? [],
    )
}

let appSdkVersion = parseVersion(appSdkVersionId)

let package = Package(
    name: "appsdk_v2_flutter_plugin",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "appsdk-v2-flutter-plugin", targets: ["appsdk_v2_flutter_plugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ihreapotheken/IA-SDK-iOS", exact: appSdkVersion)
    ],
    targets: [
        .target(
            name: "appsdk_v2_flutter_plugin",
            dependencies: [
                .product(name: "IAOverTheCounter", package: "IA-SDK-iOS"),
                .product(name: "IAOrdering", package: "IA-SDK-iOS"),
                .product(name: "IAPharmacy", package: "IA-SDK-iOS"),
                .product(name: "IAIntegrations", package: "IA-SDK-iOS"),
                .product(name: "IACardLink", package: "IA-SDK-iOS"),
                .product(name: "IAPrescription", package: "IA-SDK-iOS"),
            ],
            resources: [
                // TODO: If your plugin requires a privacy manifest
                // (e.g. if it uses any required reason APIs), update the PrivacyInfo.xcprivacy file
                // to describe your plugin's privacy impact, and then uncomment this line.
                // For more information, see:
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),
                
                // TODO: If you have other resources that need to be bundled with your plugin, refer to
                // the following instructions to add them:
                // https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package
            ]
        )
    ]
)
