part of '../impl.dart';

Future<void> _prescriptionsRedeemedHandler(dynamic args) async {
  if (args is! Map) {
    throw Exception(
      'cardLinkPrescriptionsRedeemed: Invalid arguments type.',
    );
  }
  final prescriptions = args['prescriptions'];
  if (prescriptions is! String) {
    throw Exception(
      'cardLinkPrescriptionsRedeemed: Missing or incorrect type prescriptions: ${prescriptions.runtimeType} $prescriptions.',
    );
  }
  IaModuleCardLink._prescriptionsRedeemedListener.add(prescriptions);
}
