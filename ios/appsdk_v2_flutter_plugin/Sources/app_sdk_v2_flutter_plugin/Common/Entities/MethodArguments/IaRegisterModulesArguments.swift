import Foundation

/// Arguments for registering SDK modules.
struct IaRegisterModulesArguments: Decodable {
    /// Array of SDK modules to register.
    let modules: [IaSdkModuleArguments]
}

/// SDK modules that can be registered for use in the application.
enum IaSdkModuleArguments: String, Decodable {
    case integrations = "integrations"
    case overTheCounter = "overTheCounter"
    case ordering = "ordering"
    case apofinder = "apofinder"
    case pharmacyDetails = "pharmacyDetails"
    case prescription = "prescription"
    case cardLink = "cardLink"
}
