part of '../../core.dart';

/// Analytics event logged by the SDK for the host app, reported through [IaSdk.loggedAnalyticsEventListener].
///
class IaSdkLoggedAnalyticsEvent {
  /// Constructs a new instance of the [IaSdkLoggedAnalyticsEvent] object.
  ///
  const IaSdkLoggedAnalyticsEvent({
    required this.name,
    required this.parameters,
  });

  /// Name of the event, for example `screen_view`, `add_to_cart`, `purchase` or `pharmacy_selected`.
  ///
  final String name;

  /// Values of the event, for example `screen_name` or `transaction_id`. Empty for events without values.
  ///
  final Map<String, dynamic> parameters;
}
