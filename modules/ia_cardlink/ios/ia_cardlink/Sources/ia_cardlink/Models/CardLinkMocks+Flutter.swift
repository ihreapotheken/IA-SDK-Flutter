import Foundation
import IACardLink

extension CardLinkMocks {
    static func fromFlutter(_ args: [String: Any]) -> CardLinkMocks {
        var mocks = CardLinkMocks.default
        mocks.isMockingEnabled = args["isMockingEnabled"] as? Bool ?? true

        switch args["sessionResponse"] as? String {
        case "resumeSession": mocks.sessionMock.serverResponse = .resumeSession
        case "verificationNeeded": mocks.sessionMock.serverResponse = .verificationNeeded
        case "wrongPhoneNumber": mocks.sessionMock.serverResponse = .wrongPhoneNumber
        case "serviceNotAvailable": mocks.sessionMock.serverResponse = .serviceNotAvailable
        case "otherError": mocks.sessionMock.serverResponse = .otherError
        default: mocks.sessionMock.serverResponse = .auto
        }
        if let sessionDuration = args["sessionDurationSeconds"] as? Double {
            mocks.sessionMock.sessionDuration = sessionDuration
        }
        if let willExpireSoon = args["sessionWillExpireSoonSeconds"] as? Double {
            mocks.sessionMock.willExpireSoonTimeInterval = willExpireSoon
        }

        switch args["verificationResponse"] as? String {
        case "wrongOtp": mocks.verificationMock.serverResponse = .wrongOTP
        case "expiredOtp": mocks.verificationMock.serverResponse = .expiredOTP
        case "maxAttemptsReached": mocks.verificationMock.serverResponse = .maxAttemptsReached
        case "otherError": mocks.verificationMock.serverResponse = .otherError
        default: mocks.verificationMock.serverResponse = .success
        }

        if let xmls = args["ePrescriptionXmls"] as? [String] {
            let isPartial = args["arePrescriptionsPartiallyMocked"] as? Bool ?? false
            mocks.prescriptionsMock = .init(type: isPartial ? .partiallyEPrescriptionXML(xmls) : .ePrescriptionXML(xmls))
        } else {
            mocks.prescriptionsMock = .init(type: .noMock)
        }

        let isWrongCanMocked = args["isWrongCanMocked"] as? Bool ?? false
        mocks.scanMock = .init(type: isWrongCanMocked ? .wrongCan : .noMock)
        return mocks
    }
}
