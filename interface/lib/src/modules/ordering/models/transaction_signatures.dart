part of '_models.dart';

/// Information about a completed order.
///
class IaModelOrderingTransactionSignatures {
  /// Constructs an instance of [IaModelOrderingTransactionSignatures] object.
  ///
  const IaModelOrderingTransactionSignatures({
    required this.orderCode,
    this.clientOrderIDs,
    this.orderCodes = const [],
  });

  /// Order code from backend. With several orders, the code of the first one, see [orderCodes].
  ///
  final String orderCode;

  /// Order codes of all orders the checkout created.
  ///
  final List<String> orderCodes;

  /// Order ID provided by host app using transferPrescriptions (optional).
  ///
  final List<String>? clientOrderIDs;
}
