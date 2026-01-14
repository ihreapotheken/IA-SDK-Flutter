part of '_interface.dart';

/// Defines the basic native method request parameters.
///
abstract class IaBaseRequest {
  /// Constructs a native-compatible object from this class data.
  ///
  Map<String, dynamic> toSupportedType();
}
