import Foundation
import Flutter
import IAOrdering

/// Arguments for transferring prescriptions.
struct IaTransferPrescriptionsArguments {
    let images: [Data]
    let pdfs: [Data]
    let codes: [String]
    let orderId: String?

    /// Initializes arguments from Flutter method call arguments.
    /// - Parameter arguments: Arguments object from Flutter method call
    /// - Throws: IaArgumentError if arguments format is invalid
    init(from arguments: Any) throws {
        guard let dictionary = arguments as? [String: Any] else {
            throw IaArgumentError.invalidInputArguments
        }
        self.images = (dictionary["images"] as? [FlutterStandardTypedData])?.map { $0.data } ?? []
        self.pdfs = (dictionary["pdfs"] as? [FlutterStandardTypedData])?.map { $0.data } ?? []
        self.codes = dictionary["codes"] as? [String] ?? []
        self.orderId = dictionary["orderId"] as? String
    }

    /// Maps arguments to SDK types for IAOrderingSDK.
    func mappedToSDK() -> (images: [Data], pdfs: [PDFPrescription], codes: [String], orderId: String?) {
        return (
            images: images,
            pdfs: pdfs.map { PDFPrescription(data: $0) },
            codes: codes,
            orderId: orderId
        )
    }
}
