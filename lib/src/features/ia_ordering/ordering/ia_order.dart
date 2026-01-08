/// Information about a completed order.
///
class IaModelOrder {
  /// Order code from backend.
  final String orderCode;

  /// Order ID provided by host app using transferPrescriptions (optional).
  final List<String>? clientOrderIDs;

  const IaModelOrder({
    required this.orderCode,
    this.clientOrderIDs,
  });
}
