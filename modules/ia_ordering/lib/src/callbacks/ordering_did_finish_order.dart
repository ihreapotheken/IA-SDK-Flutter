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
  final clientOrderIDs = args['clientOrderIDs'];
  if (clientOrderIDs != null && clientOrderIDs is! Iterable?) {
    throw Exception(
      'orderingDidFinishOrder: Missing or incorect type clientOrderIDs: ${clientOrderIDs.runtimeType} $clientOrderIDs.',
    );
  }
  if (clientOrderIDs != null &&
      (clientOrderIDs as Iterable).any(
        (orderId) {
          return orderId is! String;
        },
      )) {
    throw Exception(
      'orderingDidFinishOrder: Incorect type clientOrderIDs: $clientOrderIDs.',
    );
  }
  IaModuleOrdering._orderingDidFinishOrderListener.add(
    IaModelOrderingTransactionSignatures(
      orderCode: orderCode,
      clientOrderIDs: clientOrderIDs == null
          ? null
          : List<String>.from(
              clientOrderIDs,
            ),
    ),
  );
}
