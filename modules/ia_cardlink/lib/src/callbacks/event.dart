part of '../impl.dart';

Future<void> _eventHandler(dynamic args) async {
  if (args is! Map) {
    throw Exception(
      'cardLinkEvent: Invalid arguments type.',
    );
  }
  final eventType = args['event'];
  if (eventType is! String) {
    throw Exception(
      'cardLinkEvent: Missing or incorrect type event: ${eventType.runtimeType} $eventType.',
    );
  }
  final event = IaCardLinkEvent.fromRawValue(eventType);
  IaModuleCardLink._eventListener.add(event);
}
