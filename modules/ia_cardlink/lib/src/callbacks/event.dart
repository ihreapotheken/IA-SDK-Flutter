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
  // Payload streams first, so listeners of the event can rely on the payload having arrived.
  switch (event) {
    case IaCardLinkEvent.cardSaved:
      final cards = args['cards'];
      IaModuleCardLink._savedCardsListener.add(
        cards is Iterable
            ? cards.whereType<Map>().map((card) {
                return IaCardLinkSavedCard(
                  name: card['name'] as String,
                  canCode: card['canNumber'] as String?,
                  id: card['id'] as String?,
                  phoneNumber: card['phoneNumber'] as String?,
                );
              }).toList()
            : const [],
      );
    case IaCardLinkEvent.failedToInitialize:
      IaModuleCardLink._initializationErrorListener.add(args['errorMessage'] as String?);
    case IaCardLinkEvent.finished:
      IaModuleCardLink._resultListener.add(args['result'] as String?);
    default:
      break;
  }
  IaModuleCardLink._eventListener.add(event);
}
