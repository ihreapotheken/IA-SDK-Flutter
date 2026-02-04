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
            result(CardLink.environment.pluginStringValue)

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

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
