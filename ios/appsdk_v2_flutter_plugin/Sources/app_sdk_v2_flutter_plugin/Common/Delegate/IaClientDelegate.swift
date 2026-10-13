import Foundation
import IACore
import Combine
import Flutter

class IaClientDelegate: SDKDelegate {
    let channel: FlutterMethodChannel

    /// Whether SDK log messages are sent to Flutter. Only on while Dart listens, as the SDK logs a lot.
    var isLogMessageForwardingEnabled = false

    /// Values the host configured for CardLink flows the SDK starts itself.
    var cardLinkConfiguration: IaCardLinkConfigurationArguments?

    /// Posted for actions of CardLink flows the SDK starts itself, with the `CardLinkOutputAction` under the "action" key.
    /// The ia_cardlink plugin observes it to report the actions to Dart, as this plugin can't depend on it.
    static let cardLinkDidSendActionNotification = Notification.Name("de.ihreapotheken.sdk.flutter.cardLinkDidSendAction")
    
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
        case .hostAppPrivacyPolicy:
            navigationTargetString = "hostAppPrivacyPolicy"
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

    func sdkDidFinishInitialization(
        result: Result<IASDKInitializationAndPrerequisitesResult, any Error>,
        type: SDKInitializationType
    ) {
        guard case .success(let initializationResult) = result,
              let prerequisites = initializationResult.prerequisitesResult else {
            return
        }
        let onboarding: String = switch prerequisites.onboardingResult {
        case .notStarted: "notStarted"
        case .noOnboardingData: "noOnboardingData"
        case .finished: "finished"
        case .cancelled: "cancelled"
        @unknown default: "notStarted"
        }
        let legal: String = switch prerequisites.legalResult {
        case .accepted: "accepted"
        case .cancelled: "cancelled"
        case .notStarted: "notStarted"
        case .noLegalTextFound: "noLegalTextFound"
        @unknown default: "notStarted"
        }
        channel.invokeMethod(
            "sdkPrerequisitesFinished",
            arguments: [
                "isCancelled": prerequisites.isCancelled,
                "onboarding": onboarding,
                "legal": legal,
                "pharmacyId": prerequisites.pharmacyResult.pharmacyID.map { String($0) } ?? NSNull(),
            ] as [String: Any]
        )
    }

    func cardLinkWillStartWithConfiguration(configuration: CardLinkConfiguration) -> CardLinkConfiguration {
        cardLinkConfiguration?.applied(to: configuration) ?? configuration
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
                "level": level.title,
            ]
        )
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

    /// Asks Flutter how the SDK should continue with a scanned prescription.
    /// Any missing or invalid answer, for example when the prescription module isn't used in Dart, keeps the SDK default.
    private func requestScanResult(method: String, arguments: [String: Any]) async -> IAPrescriptionScanResult {
        await withCheckedContinuation { continuation in
            channel.invokeMethod(method, arguments: arguments) { result in
                guard let response = result as? [String: Any],
                      let decision = response["decision"] as? String else {
                    continuation.resume(returning: .performDefault)
                    return
                }
                switch decision {
                case "handled":
                    continuation.resume(returning: .handled)
                case "error":
                    continuation.resume(returning: .error(message: response["message"] as? String ?? ""))
                default:
                    continuation.resume(returning: .performDefault)
                }
            }
        }
    }
}
