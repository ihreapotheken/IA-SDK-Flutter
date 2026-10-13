import Flutter
import UIKit
import IACore
import IACardLink

@MainActor
public class IaSdkFlutterCardLink: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?

    private let eventSender = CardLinkEventSender()
    private lazy var launchHandler = LaunchHandler(eventSender: eventSender)
    private let getSavedCardsHandler = GetSavedCardsHandler()
    private let deleteCardHandler = DeleteCardHandler()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "de.ihreapotheken/sdk/cardLink",
            binaryMessenger: registrar.messenger()
        )
        let instance = IaSdkFlutterCardLink()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.channel = channel
        instance.eventSender.setMethodChannel(channel)

        // Actions of CardLink flows the SDK starts itself reach the SDK delegate in the core plugin, which posts them.
        NotificationCenter.default.addObserver(
            forName: Notification.Name("de.ihreapotheken.sdk.flutter.cardLinkDidSendAction"),
            object: nil,
            queue: .main
        ) { [weak instance] notification in
            guard let action = notification.userInfo?["action"] as? CardLinkOutputAction else { return }
            Task { @MainActor in
                instance?.launchHandler.handleSdkFlowOutputAction(action)
            }
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "register":
            IASDK.register([IASDKModule.cardLink])
            result(nil)

        case "launch":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments received", details: nil))
                return
            }
            launchHandler.handle(args: args, result: result)

        case "getVersion":
            result(CardLink.version)

        case "getEnvironment":
            let environment = IASDK.getEnvironment()
            let value: String = switch environment {
            case .prod: "PRODUCTION"
            case .dev, .staging: "DEBUG"
            }
            result(value)

        case "getLogFilePath":
            result(CardLink.logsPath)

        case "getSavedCards":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments received", details: nil))
                return
            }
            getSavedCardsHandler.handle(args: args, result: result)

        case "deleteCard":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments received", details: nil))
                return
            }
            deleteCardHandler.handle(args: args, result: result)

        case "deleteAllCards":
            do {
                let status = try CardLink.deleteAllCards()
                result("\(status)")
            } catch {
                result(FlutterError(code: "DELETE_ALL_CARDS_ERROR", message: "\(error)", details: nil))
            }

        case "deleteAllUserRelatedData":
            Task {
                do {
                    try await CardLink.deleteAllUserRelatedData()
                    result(nil)
                } catch {
                    result(FlutterError(code: "DELETE_ALL_USER_DATA_ERROR", message: "\(error)", details: nil))
                }
            }

        case "setHostAppLogFilePath":
            guard let path = (call.arguments as? [String: Any])?["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "path is required", details: nil))
                return
            }
            IASDK.configuration.hostAppLogFileURL = path.isEmpty ? nil : URL(fileURLWithPath: path)
            result(nil)

        case "setMocks":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments received", details: nil))
                return
            }
            CardLink.setMocks(CardLinkMocks.fromFlutter(args))
            result(nil)

        case "finish":
            CardLink.finish {
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
