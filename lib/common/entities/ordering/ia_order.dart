/// Information about a completed order.
///
class IaOrder {
  /// Order code from backend.
  final String orderCode;

  /// Order ID provided by host app using transferPrescriptions (optional).
  final List<String>? clientOrderIDs;

  const IaOrder({
    required this.orderCode,
    this.clientOrderIDs,
  });
}
