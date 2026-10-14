part of '../impl.dart';

Future<void> _sessionCreatedHandler(dynamic args) async {
  if (args is! Map) {
    throw Exception(
      'cardLinkSessionCreated: Invalid arguments type.',
    );
  }
  final sessionData = args['session'];
  // Platform channels deliver maps as Map<Object?, Object?>, so convert instead of type-checking for Map<String, dynamic>.
  if (sessionData is! Map) {
    throw Exception(
      'cardLinkSessionCreated: Missing or incorrect type session: ${sessionData.runtimeType} $sessionData.',
    );
  }
  final session = IaCardLinkSession.fromMap(Map<String, dynamic>.from(sessionData));
  IaModuleCardLink._sessionCreatedListener.add(session);
}
