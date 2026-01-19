import 'dart:async';
import 'dart:typed_data';

import 'package:ia_interface/ia_interface.dart';

part 'methods.dart';
part 'views.dart';
part 'models/request/transfer_prescriptions.dart';
part 'callbacks/_callbacks.dart';
part 'callbacks/ordering_did_finish_order.dart';
part 'callbacks/ordering_did_update_cart.dart';

/// Method and property definitions for the ia.de AppSDK Ordering service.
///
class IaModuleOrdering extends IaBaseOrdering {
  @override
  Future<void> transferPrescriptions({
    Iterable<Uint8List>? images,
    Iterable<Uint8List>? pdfs,
    Iterable<String>? codes,
    String? orderId,
  }) async {
    final arguments = _RequestModelTransferPrescriptions(
      images: images,
      pdfs: pdfs,
      codes: codes,
      orderId: orderId,
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
  final callbacks = IaBaseCallbacks(
    handlers: _Callbacks.values,
  );
}
