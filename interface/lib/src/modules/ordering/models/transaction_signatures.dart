part of '_models.dart';

/// Information about a completed order.
///
class IaModelOrderingTransactionSignatures {
  /// Constructs an instance of [IaModelOrderingTransactionSignatures] object.
  ///
  const IaModelOrderingTransactionSignatures({
    required this.orderCode,
    this.clientOrderIDs,
  });

  /// Order code from backend.
  ///
  final String orderCode;

  /// Order ID provided by host app using transferPrescriptions (optional).
  ///
  final List<String>? clientOrderIDs;
}
