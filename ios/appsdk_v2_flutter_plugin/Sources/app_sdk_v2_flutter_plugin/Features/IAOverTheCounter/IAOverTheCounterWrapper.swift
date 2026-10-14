import Foundation
import IACore
import IAIntegrations

@MainActor
final class IAOverTheCounterWrapper {
    private let argumentDecoder = IaArgumentDecoder()

    func clearProductGridCache() async throws -> Any? {
        let overTheCounter = try IASDK.overTheCounter
        await overTheCounter.clearProductGridCache()
        return nil
    }
}
