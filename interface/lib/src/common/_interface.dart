import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ia_interface/ia_interface.dart';

part 'callbacks.dart';
part 'methods.dart';
part 'modules.dart';
part 'request.dart';
part 'views.dart';
part '../modules/cardlink/cardlink.dart';
part '../modules/ordering/ordering.dart';
part '../modules/over_the_counter/over_the_counter.dart';
part '../modules/pharmacy/pharmacy.dart';
part '../modules/prescription/prescription.dart';

/// Base definition for an ia.de module service.
///
abstract class IaBase {
  /// Unnamed constructor used to allocate library resources.
  ///
  IaBase() {
    IaBaseCallbacks._ensureSharedChannelHandler();
    // Modules share their callbacks between instances and create them lazily; reading them registers the handlers.
    callbacks;
    final moduleChannelId = IaBaseMethods._channelId + '/${module.name}';
    final moduleMethodChannel = MethodChannel(moduleChannelId);
    nativeRegistration = moduleMethodChannel.invokeMethod<void>('register');
    // Logged here too, since a module that's never passed to IaSdk.register has no one awaiting the result.
    nativeRegistration.catchError(
      (Object e) {
        debugPrint('Error registering ${module.name} module: $e');
      },
    );
  }

  /// Registration of the module with its native plugin, started when the module is created.
  ///
  /// Fails when the module's native part is missing. `IaSdk.register` waits for it.
  ///
  late final Future<void> nativeRegistration;

  /// Relevant [IaBaseModule] with functionality extended by this base class.
  ///
  IaBaseModule get module {
    throw UnimplementedError(
      'Property "module" not defined for $runtimeType.',
    );
  }

  /// Default module native callback definitions.
  ///
  /// Read when the module is created, which registers its handlers. Return the same object for every instance,
  /// since each [IaBaseCallbacks] stays registered.
  ///
  IaBaseCallbacks? get callbacks {
    return null;
  }
}
