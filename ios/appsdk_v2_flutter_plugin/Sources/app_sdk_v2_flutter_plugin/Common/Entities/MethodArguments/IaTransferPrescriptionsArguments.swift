import Foundation
import Flutter
import IACore

/// Arguments for transferring prescriptions.
struct IaTransferPrescriptionsArguments {
    let images: [Data]
    let pdfs: [(data: Data, insuranceType: PrescriptionInsuranceType)]
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
        self.pdfs = (dictionary["pdfs"] as? [[String: Any]])?.compactMap { pdfDict in
            guard let typedData = pdfDict["data"] as? FlutterStandardTypedData else { return nil }
            let insuranceType: PrescriptionInsuranceType
            switch pdfDict["insuranceType"] as? String {
            case "privateInsurance":
                insuranceType = .privateInsurance
            case "publicHealthcare":
                insuranceType = .publicHealthcare
            default:
                insuranceType = .publicHealthcare
            }
            return (data: typedData.data, insuranceType: insuranceType)
        } ?? []
        self.codes = dictionary["codes"] as? [String] ?? []
        self.orderId = dictionary["orderId"] as? String
    }

    /// Maps arguments to SDK types for IAOrderingSDK.
    func mappedToSDK() -> (images: [Data], pdfs: [PDFPrescription], codes: [String], orderId: String?) {
        return (
            images: images,
            pdfs: pdfs.map { PDFPrescription(data: $0.data, insuranceType: $0.insuranceType) },
            codes: codes,
            orderId: orderId
        )
    }
}
