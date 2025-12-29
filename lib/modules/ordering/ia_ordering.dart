import 'package:flutter/foundation.dart';
import 'package:appsdk_v2_flutter_plugin/common/utilities/argument_validator.dart';
import 'package:appsdk_v2_flutter_plugin/common/utilities/ia_sdk_channel.dart';

/// Ordering module for the IA SDK.
///
/// Provides functionality related to prescriptions, cart, and checkout.
/// This mirrors the IAOrdering module from the native SDKs.
///
class IaOrdering {
  /// Creates an instance of [IaOrdering].
  ///
  const IaOrdering();

  /// Forwards the specified [images], [pdfs], or eRezept [codes] prescription collection to the ia.de backend.
  ///
  Future<void> transferPrescriptions({
    Iterable<Uint8List>? images,
    Iterable<Uint8List>? pdfs,
    Iterable<String>? codes,
    String? orderId,
  }) async {
    final arguments = {
      'images': images,
      'pdfs': pdfs,
      'codes': codes,
      'orderId': orderId,
    };

    ArgumentValidator.verify(
      arguments,
      argumentType: Map,
      requiredMapFields: [
        (
          name: 'images',
          type: Iterable<Uint8List>,
          nullable: true,
        ),
        (
          name: 'pdfs',
          type: Iterable<Uint8List>,
          nullable: true,
        ),
        (
          name: 'codes',
          type: Iterable<String>,
          nullable: true,
        ),
        (
          name: 'orderId',
          type: String,
          nullable: true,
        ),
      ],
    );

    await IaSdkChannel.instance.channel.invokeMethod(
      'transferPrescriptions',
      arguments,
    );
  }
}
