part of '_models.dart';

/// Information about a completed order.
///
class IaModelOrderingTransactionSignatures {
  /// Constructs an instance of [IaModelOrderingTransactionSignatures] object.
  ///
  const IaModelOrderingTransactionSignatures({
    required this.orderCode,
    this.clientOrderIDs = const [],
    this.orderCodes = const [],
  });

  /// Order code from backend. With several orders, the code of the first one, see [orderCodes].
  ///
  final String orderCode;

  /// Order codes of all orders the checkout created.
  ///
  final List<String> orderCodes;

  /// Order IDs the host app passed to transferPrescriptions. Empty when it passed none.
  ///
  final List<String> clientOrderIDs;
}
