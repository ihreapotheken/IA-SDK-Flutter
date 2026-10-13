import Combine
import IACore
import SwiftUI

/// Camera state of the prescription scanner launched from Flutter, which Dart can change while it's shown.
@MainActor
final class PrescriptionScannerCameraController: ObservableObject {
    static let shared = PrescriptionScannerCameraController()

    @Published var state = IACameraState()

    /// Reports camera errors of the scanner.
    var onError: ((any Error) -> Void)?

    /// Every launch starts with the camera on, the flashlight off and the preview running.
    func reset() {
        state = IACameraState()
    }
}

/// Prescription scanner whose camera state is driven by [PrescriptionScannerCameraController].
///
/// The SDK screen only takes the camera state as a SwiftUI binding, so this screen observes the controller
/// and passes its state down, re-rendering the scanner whenever Dart changes it.
@MainActor
struct CameraControlledPrescriptionScannerScreen: IAScreen {
    private var scanner: IAPrescriptionScannerScreen
    private let controller: PrescriptionScannerCameraController

    init(type: IAPrescriptionScannerType, controller: PrescriptionScannerCameraController = .shared) {
        self.scanner = IAPrescriptionScannerScreen(type: type)
        self.controller = controller
    }

    var routeIdentifier: IARouteIdentifier {
        scanner.routeIdentifier
    }

    var entitlements: [Entitlement] {
        scanner.entitlements
    }

    var hostEmbedStyle: IAEmbedStyle? {
        get { scanner.hostEmbedStyle }
        set { scanner.hostEmbedStyle = newValue }
    }

    func content(navigator: any Navigator) -> some View {
        CameraControlledScannerContent(scanner: scanner, controller: controller, navigator: navigator)
    }
}

@MainActor
private struct CameraControlledScannerContent: View {
    let scanner: IAPrescriptionScannerScreen
    @ObservedObject var controller: PrescriptionScannerCameraController
    let navigator: any Navigator

    var body: some View {
        scanner
            .cameraState($controller.state)
            .onCameraError { [controller] error in
                controller.onError?(error)
            }
            .content(navigator: navigator)
    }
}
