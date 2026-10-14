import 'dart:async';
import 'dart:typed_data';

import 'package:ia_interface/ia_interface.dart';

part 'methods.dart';
part 'views.dart';
part 'models/request/transfer_prescriptions.dart';
part 'models/request/get_cart_details.dart';
part 'callbacks/_callbacks.dart';
part 'callbacks/ordering_did_finish_order.dart';
part 'callbacks/ordering_did_update_cart.dart';

/// Method and property definitions for the ia.de AppSDK Ordering service.
///
class IaModuleOrdering extends IaBaseOrdering {
  @override
  Future<void> transferPrescriptions({
    Iterable<Uint8List>? images,
    Iterable<({Uint8List data, IaPrescriptionInsuranceType insuranceType})>? pdfs,
    Iterable<String>? codes,
    String? orderId,
    IaTransferPrescriptionsFinishAction finishAction = IaTransferPrescriptionsFinishAction.openCart,
    bool showActivityIndicator = true,
  }) async {
    final arguments = _RequestModelTransferPrescriptions(
      images: images,
      pdfs: pdfs,
      codes: codes,
      orderId: orderId,
      finishAction: finishAction,
      showActivityIndicator: showActivityIndicator,
    );
    return await _Methods.transferPrescriptions.invoke<void>(
      arguments,
    );
  }

  @override
  Future<void> clearCart() async {
    return await _Methods.clearCart.invoke<void>(null);
  }

  @override
  Future<Map<String, dynamic>?> getCartDetails({
    bool allowCached = true,
    bool shouldEmitCartUpdate = false,
  }) async {
    final arguments = _RequestModelGetCartDetails(
      allowCached: allowCached,
      shouldEmitCartUpdate: shouldEmitCartUpdate,
    );
    final result = await _Methods.getCartDetails.invoke<Map?>(arguments);
    if (result == null) return null;
    return _stringKeyed(result) as Map<String, dynamic>;
  }

  /// Platform channels deliver nested maps as `Map<Object?, Object?>`.
  ///
  static Object? _stringKeyed(Object? value) {
    if (value is Map) {
      return value.map((key, nested) => MapEntry('$key', _stringKeyed(nested)));
    }
    if (value is List) {
      return value.map(_stringKeyed).toList();
    }
    return value;
  }

  @override
  Future<IaModelOrderingCartState?> getCartState({
    bool allowCached = true,
    bool shouldEmitCartUpdate = false,
  }) async {
    final details = await getCartDetails(
      allowCached: allowCached,
      shouldEmitCartUpdate: shouldEmitCartUpdate,
    );
    if (details == null) return null;
    final products = details['products'];
    return IaModelOrderingCartState(
      totalAmountInCart: details['totalAmountInCart'] as int,
      clientOrderIDs: const [],
      products: products is Iterable
          ? products.whereType<Map>().map((product) {
              return IaModelOrderingCartProduct(
                pzn: product['pzn'] as String,
                amount: product['amount'] as int,
              );
            }).toList()
          : const [],
    );
  }

  @override
  Future<void> deleteOrderHistory() async {
    return await _Methods.deleteOrderHistory.invoke<void>(null);
  }

  @override
  Future<void> launchCartScreen() async {
    return await _Views.cartScreen.launch();
  }

  static final _orderingDidFinishOrderListener = StreamController<IaModelOrderingTransactionSignatures>.broadcast();

  @override
  StreamController<IaModelOrderingTransactionSignatures> get orderingDidFinishOrderListener {
    return _orderingDidFinishOrderListener;
  }

  static final _orderingDidUpdateCartListener = StreamController<IaModelOrderingCartState>.broadcast();

  @override
  StreamController<IaModelOrderingCartState> get orderingDidUpdateCartListener {
    return _orderingDidUpdateCartListener;
  }

  @override
  IaBaseCallbacks get callbacks {
    return _callbacks;
  }

  // Shared by all instances, like the streams, so creating more instances doesn't add more subscribers.
  static final _callbacks = IaBaseCallbacks(
    handlers: _Callbacks.values,
  );
}
