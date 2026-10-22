import Foundation
import IACore
import Combine
import Flutter

class IaClientDelegate: SDKDelegate {
    let channel: FlutterMethodChannel

    /// Whether SDK log messages are sent to Flutter. Only on while Dart listens, as the SDK logs a lot.
    var isLogMessageForwardingEnabled = false

    /// Static, so a delegate created for another Flutter engine keeps them.
    static var cardLinkConfiguration: IaCardLinkConfigurationArguments?

    /// How long the SDK waits for Flutter's scan decision. Without an answer, for example when the Flutter engine is
    /// gone, it continues with its default handling.
    private static let scanDecisionTimeout: TimeInterval = 120

    /// Posted for actions of CardLink flows the SDK starts itself, with the `CardLinkOutputAction` under the "action" key.
    /// The ia_cardlink plugin observes it to report the actions to Dart, as this plugin can't depend on it.
    static let cardLinkDidSendActionNotification = Notification.Name("de.ihreapotheken.sdk.flutter.cardLinkDidSendAction")

    /// Posted when `initialize` set the SDK environment, which the ia_cardlink plugin's launches without an
    /// environment then keep.
    static let sdkEnvironmentWasSetNotification = Notification.Name("de.ihreapotheken.sdk.flutter.sdkEnvironmentWasSet")

    /// Posted when `finishAllActivities` closed a CardLink flow shown on top of an SDK screen, for the ia_cardlink
    /// plugin to report its closing.
    static let cardLinkDidCloseWithSdkScreensNotification = Notification.Name("de.ihreapotheken.sdk.flutter.cardLinkDidCloseWithSdkScreens")
    
    init(
        channel: FlutterMethodChannel,
    ) {
        self.channel = channel
    }
    
    func sdkWillNavigateToTarget(_ navigationTarget: IANavigationTarget, decisionHandler: @escaping (HandlingDecision) -> Void) {
        // Convert navigation target to string
        let navigationTargetString: String
        switch navigationTarget {
        case .cart:
            navigationTargetString = "cart"
        case .pharmacyDetails:
            navigationTargetString = "pharmacyDetails"
        case .thankYou:
            navigationTargetString = "thankYou"
        case .imprint:
            navigationTargetString = "imprint"
        case .apofinder:
            navigationTargetString = "apofinder"
        }
        
        // Call Flutter callback and wait for response
        channel.invokeMethod(
            "sdkWillNavigateToTarget",
            arguments: ["navigationTarget": navigationTargetString]
        ) { result in
            // Parse the response
            guard let decisionString = result as? String else {
                // If no valid response, perform default
                decisionHandler(.performDefault)
                return
            }
            
            // Convert string to HandlingDecision
            let decision: HandlingDecision
            switch decisionString {
            case "handled":
                decision = .handled
            case "performDefault":
                decision = .performDefault
            default:
                decision = .performDefault
            }
            
            decisionHandler(decision)
        }
    }
    
    func apofinderDidChangePharmacy(_ pharmacy: Pharmacy, isFromPrerequisites: Bool) {
        channel.invokeMethod(
            "apofinderDidChangePharmacy",
            arguments: [
                "pharmacyId": String(pharmacy.id),
                "isFromPrerequisites": isFromPrerequisites,
            ] as [String: Any]
        )
    }

    func orderingDidFinishOrders(orders: [IAOrder]) {
        guard let orderCode = orders.first?.orderCode else { return }
        let clientOrderIDs = orders.compactMap(\.clientOrderID)
        
        channel.invokeMethod(
            "orderingDidFinishOrder",
            arguments: [
                "orderCode": orderCode,
                "orderCodes": orders.map(\.orderCode),
                "clientOrderIDs": clientOrderIDs,
            ],
        )
    }
    
    func orderingDidUpdateCart(cartState: IACartState) {
        // Extract totalAmountInCart from cartDetails, default to 0 if nil
        let totalAmountInCart = cartState.cartDetails?.totalAmountInCart ?? 0
        
        let products: Any = cartState.cartDetails.map { details in
            details.products.map { ["pzn": $0.pzn, "amount": $0.amount] as [String: Any] }
        } ?? NSNull()
        let arguments: [String: Any] = [
            "totalAmountInCart": totalAmountInCart,
            "clientOrderIDs": cartState.clientOrderIDs,
            "products": products,
        ]
        
        // Send to Flutter
        channel.invokeMethod(
            "orderingDidUpdateCart",
            arguments: arguments
        )
    }

    func cardLinkWillStartWithConfiguration(configuration: CardLinkConfiguration) -> CardLinkConfiguration {
        Self.cardLinkConfiguration?.applied(to: configuration) ?? configuration
    }

    func cardLinkDidSendAction(action: CardLinkOutputAction) -> HandlingDecision {
        NotificationCenter.default.post(
            name: Self.cardLinkDidSendActionNotification,
            object: nil,
            userInfo: ["action": action]
        )
        return .performDefault
    }

    func sdkDidLogMessage(_ message: String, level: IALogLevel) {
        guard isLogMessageForwardingEnabled else { return }
        channel.invokeMethod(
            "sdkDidLogMessage",
            arguments: [
                "message": message,
                "level": Self.levelName(level),
            ]
        )
    }

    /// Stable names for the SDK's log levels, matching the Dart doc of `IaSdkLogMessage.level`.
    private static func levelName(_ level: IALogLevel) -> String {
        switch level {
        case .debug: "debug"
        case .info: "info"
        case .warning: "warning"
        case .error: "error"
        case .userInteraction: "userInteraction"
        case .cameraError: "cameraError"
        case .httpClientInfo: "httpClientInfo"
        case .httpClientSuccess: "httpClientSuccess"
        case .httpClientError: "httpClientError"
        default: level.title
        }
    }

    func sdkDidLogAnalyticsEvent(_ event: IAAnalyticsEvent) {
        channel.invokeMethod(
            "sdkDidLogAnalyticsEvent",
            arguments: [
                "name": event.name,
                "parameters": event.parameters.mapValues(Self.channelValue),
            ] as [String: Any]
        )
    }

    /// The parameter value in a type the method channel can send. Other values are sent as their description, as the
    /// channel would fail on them.
    private static func channelValue(_ value: Any) -> Any {
        switch value {
        case is String, is NSNumber, is NSNull:
            value
        case let array as [Any]:
            array.map(channelValue)
        case let dictionary as [String: Any]:
            dictionary.mapValues(channelValue)
        default:
            String(describing: value)
        }
    }

    func didScanPrescription(_ prescription: Data) async -> IAPrescriptionScanResult {
        await requestScanResult(
            method: "prescriptionPhotoScanned",
            arguments: ["imageData": FlutterStandardTypedData(bytes: prescription)]
        )
    }

    func didScanEPrescription(_ ePrescription: EPrescriptionData) async -> IAPrescriptionScanResult {
        await requestScanResult(
            method: "ePrescriptionScanned",
            arguments: [
                "rawCode": ePrescription.rawCode,
                "urls": ePrescription.urls,
            ] as [String: Any]
        )
    }

    private func requestScanResult(method: String, arguments: [String: Any]) async -> IAPrescriptionScanResult {
        await withCheckedContinuation { continuation in
            // Resumed by Flutter's answer or the timeout, whichever comes first.
            let resumer = ScanResultResumer(continuation)
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.scanDecisionTimeout) {
                resumer.resume(.performDefault)
            }
            channel.invokeMethod(method, arguments: arguments) { result in
                guard let response = result as? [String: Any],
                      let decision = response["decision"] as? String else {
                    resumer.resume(.performDefault)
                    return
                }
                switch decision {
                case "handled":
                    resumer.resume(.handled)
                case "error":
                    resumer.resume(.error(message: response["message"] as? String ?? ""))
                default:
                    resumer.resume(.performDefault)
                }
            }
        }
    }
}

/// Resumes a scan decision continuation once; later answers are ignored. Only used on the main thread.
private final class ScanResultResumer: @unchecked Sendable {
    private var continuation: CheckedContinuation<IAPrescriptionScanResult, Never>?

    init(_ continuation: CheckedContinuation<IAPrescriptionScanResult, Never>) {
        self.continuation = continuation
    }

    func resume(_ result: IAPrescriptionScanResult) {
        continuation?.resume(returning: result)
        continuation = nil
    }
}
