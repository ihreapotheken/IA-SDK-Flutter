import IACore
import IACardLink

extension IACore.CardLinkConfiguration {
    init(args: [String: Any]) {
        let pharmacyId = args["pharmacyId"] as? String ?? ""
        let consentStatusString = args["consentStatus"] as? String ?? "SHOW_CONSENT"
        let phoneNumber = args["phoneNumber"] as? String ?? ""
        let environmentString = args["environment"] as? String ?? "PRODUCTION"
        let userId = args["userId"] as? String
        let canCode = args["canCode"] as? String
        let cardName = args["cardName"] as? String
        let isSaveCardEnabled = args["saveCardEnabled"] as? Bool ?? true

        let consentStatus: CardLinkConsentStatus
        switch consentStatusString {
        case "CONSENT_ACCEPTED":
            consentStatus = .accepted
        case "CONSENT_DECLINED":
            consentStatus = .declined
        default:
            consentStatus = .undetermined
        }

        CardLink.environment = CLEnvironment(pluginStringValue: environmentString)

        self.init(
            pharmacyId: pharmacyId,
            consentStatus: consentStatus,
            canCode: canCode,
            phoneNumber: phoneNumber,
            userId: userId ?? "guest_user_id",
            cardName: cardName,
            isSaveCardEnabled: isSaveCardEnabled
        )
    }
}
