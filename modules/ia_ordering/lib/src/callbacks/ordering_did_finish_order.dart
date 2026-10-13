part of '../impl.dart';

Future<void> _orderingDidFinishOrderHandler(dynamic args) async {
  if (args is! Map) {
    throw Exception(
      'orderingDidFinishOrder: Invalid arguments type.',
    );
  }
  final orderCode = args['orderCode'];
  if (orderCode is! String) {
    throw Exception(
      'orderingDidFinishOrder: Missing or incorrect type orderCode: ${orderCode.runtimeType} $orderCode.',
    );
  }
  final clientOrderIDs = args['clientOrderIDs'] ?? const [];
  if (clientOrderIDs is! Iterable) {
    throw Exception(
      'orderingDidFinishOrder: Incorrect type clientOrderIDs: ${clientOrderIDs.runtimeType} $clientOrderIDs.',
    );
  }
  if (clientOrderIDs.any(
    (orderId) {
      return orderId is! String;
    },
  )) {
    throw Exception(
      'orderingDidFinishOrder: Incorrect type clientOrderIDs: $clientOrderIDs.',
    );
  }
  final orderCodes = args['orderCodes'];
  IaModuleOrdering._orderingDidFinishOrderListener.add(
    IaModelOrderingTransactionSignatures(
      orderCode: orderCode,
      orderCodes: orderCodes is Iterable ? orderCodes.whereType<String>().toList() : [orderCode],
      clientOrderIDs: List<String>.from(
        clientOrderIDs,
      ),
    ),
  );
}
