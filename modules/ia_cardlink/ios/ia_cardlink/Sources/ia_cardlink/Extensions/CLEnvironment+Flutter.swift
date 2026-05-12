import IACardLink

extension CLEnvironment {
    init(pluginStringValue: String) {
        self = pluginStringValue == "DEBUG" ? .debugQA : .production
    }

    var pluginStringValue: String {
        switch self {
        case .debugDEV, .debugQA:
            return "DEBUG"
        default:
            return "PRODUCTION"
        }
    }
}
