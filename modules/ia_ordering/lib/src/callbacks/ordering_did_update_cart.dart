part of '../impl.dart';

Future<void> _orderingDidUpdateCartHandler(dynamic args) async {
  if (args is! Map) {
    throw Exception(
      'orderingDidUpdateCart: Invalid arguments type.',
    );
  }
  final totalAmountInCart = args['totalAmountInCart'];
  if (totalAmountInCart is! int) {
    throw Exception(
      'orderingDidUpdateCart: Missing or incorrect type totalAmountInCart: ${totalAmountInCart.runtimeType} $totalAmountInCart.',
    );
  }
  final clientOrderIDs = args['clientOrderIDs'];
  if (clientOrderIDs is! Iterable) {
    throw Exception(
      'orderingDidFinishOrder: Missing or incorect type clientOrderIDs: ${clientOrderIDs.runtimeType} $clientOrderIDs.',
    );
  }
  if (clientOrderIDs.any(
    (orderId) {
      return orderId is! String;
    },
  )) {
    throw Exception(
      'orderingDidFinishOrder: Incorect type clientOrderIDs: $clientOrderIDs.',
    );
  }
  IaModuleOrdering._orderingDidUpdateCartListener.add(
    IaModelOrderingCartState(
      totalAmountInCart: totalAmountInCart,
      clientOrderIDs: List<String>.from(
        clientOrderIDs,
      ),
    ),
  );
}
