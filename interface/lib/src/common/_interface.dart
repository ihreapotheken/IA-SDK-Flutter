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
    IaBaseCallbacks._instance;
    final moduleChannelId = IaBaseMethods._channelId + '/${module.name}';
    final moduleMethodChannel = MethodChannel(moduleChannelId);
    moduleMethodChannel.invokeMethod('register').catchError(
      (e) {
        debugPrint('Error registering ${module.name} module: $e');
      },
    );
  }

  /// Relevant [IaBaseModule] with functionality extended by this base class.
  ///
  IaBaseModule get module {
    throw UnimplementedError(
      'Property "module" not defined for $runtimeType.',
    );
  }

  /// Default module native callback definitions.
  ///
  IaBaseCallbacks? get callbacks {
    return null;
  }
}
