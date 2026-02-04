part of '../impl.dart';

Future<void> _sessionCreatedHandler(dynamic args) async {
  if (args is! Map) {
    throw Exception(
      'cardLinkSessionCreated: Invalid arguments type.',
    );
  }
  final sessionData = args['session'];
  if (sessionData is! Map<String, dynamic>) {
    throw Exception(
      'cardLinkSessionCreated: Missing or incorrect type session: ${sessionData.runtimeType} $sessionData.',
    );
  }
  final session = IaCardLinkSession.fromMap(sessionData);
  IaModuleCardLink._sessionCreatedListener.add(session);
}
