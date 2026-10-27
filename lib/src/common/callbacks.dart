part of '../core.dart';

class _InitializationStateHandler implements IaBaseCallbackHandler {
  const _InitializationStateHandler();

  @override
  String get methodId => 'sdkInitializationStateChanged';

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      final rawState = args is Map ? args['state'] : null;
      final state = IaSdkInitializationState.values.where((value) => value.name == rawState).firstOrNull;
      if (state == null) {
        throw Exception(
          'sdkInitializationStateChanged: Missing or invalid state: $args.',
        );
      }
      IaSdk.instance.initializationStateListener.add(state);
      return null;
    };
  }
}

class _LoggedAnalyticsEventHandler implements IaBaseCallbackHandler {
  const _LoggedAnalyticsEventHandler();

  @override
  String get methodId => 'sdkDidLogAnalyticsEvent';

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      final name = args is Map ? args['name'] : null;
      final parameters = args is Map ? args['parameters'] : null;
      if (name is! String || parameters is! Map) {
        throw Exception(
          'sdkDidLogAnalyticsEvent: Missing or incorrect event fields: $args.',
        );
      }
      IaSdk.instance.loggedAnalyticsEventListener.add(
        IaSdkLoggedAnalyticsEvent(
          name: name,
          parameters: Map<String, dynamic>.from(parameters),
        ),
      );
      return null;
    };
  }
}

class _LogMessageHandler implements IaBaseCallbackHandler {
  const _LogMessageHandler();

  @override
  String get methodId => 'sdkDidLogMessage';

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      final message = args is Map ? args['message'] : null;
      final level = args is Map ? args['level'] : null;
      if (message is! String || level is! String) {
        throw Exception(
          'sdkDidLogMessage: Missing or incorrect message fields: $args.',
        );
      }
      IaSdk.instance.logMessageListener.add(
        IaSdkLogMessage(
          message: message,
          level: level,
        ),
      );
      return null;
    };
  }
}

class _BackActionHandler implements IaBaseCallbackHandler {
  const _BackActionHandler();

  @override
  String get methodId => 'sdkBackAction';

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      return await IaSdk.instance.onSdkBackAction?.call() ?? true;
    };
  }
}

