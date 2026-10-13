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

class _AnalyticsEventHandler implements IaBaseCallbackHandler {
  const _AnalyticsEventHandler();

  @override
  String get methodId => 'sdkAnalyticsEvent';

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      if (args is! Map) {
        throw Exception(
          'sdkAnalyticsEvent: Invalid arguments type.',
        );
      }
      final type = args['type'];
      final eventId = args['eventId'];
      final sessionId = args['sessionId'];
      final timestamp = args['timestamp'];
      final parameters = args['parameters'];
      if (type is! String || eventId is! String || sessionId is! String || timestamp is! int || parameters is! Map) {
        throw Exception(
          'sdkAnalyticsEvent: Missing or incorrect event fields: $args.',
        );
      }
      IaSdk.instance.analyticsEventListener.add(
        IaSdkAnalyticsEvent(
          type: type,
          eventId: eventId,
          sessionId: sessionId,
          timestamp: timestamp,
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

class _PrerequisitesResultHandler implements IaBaseCallbackHandler {
  const _PrerequisitesResultHandler();

  @override
  String get methodId => 'sdkPrerequisitesFinished';

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      final isCancelled = args is Map ? args['isCancelled'] : null;
      if (isCancelled is! bool) {
        throw Exception(
          'sdkPrerequisitesFinished: Missing or invalid isCancelled: $args.',
        );
      }
      final map = args as Map;
      IaSdk.instance.prerequisitesResultListener.add(
        IaSdkPrerequisitesResult(
          isCancelled: isCancelled,
          onboarding: IaSdkOnboardingResult.values.where((value) => value.name == map['onboarding']).firstOrNull,
          legal: IaSdkLegalResult.values.where((value) => value.name == map['legal']).firstOrNull,
          pharmacyId: map['pharmacyId'] as String?,
        ),
      );
      return null;
    };
  }
}
