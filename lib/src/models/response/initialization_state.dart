part of '../../core.dart';

/// Initialization state of the SDK, reported through [IaSdk.initializationStateListener].
///
/// {@category Initialization}
enum IaSdkInitializationState {
  /// The SDK hasn't started initializing.
  ///
  uninitialized,

  /// The SDK is initializing.
  ///
  initializing,

  /// The SDK finished initializing and can be used.
  ///
  initialized,

  /// Initialization failed.
  ///
  error,
}
