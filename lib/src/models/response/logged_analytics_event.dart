part of '../../core.dart';

/// Analytics event logged by the SDK for the host app, reported through [IaSdk.loggedAnalyticsEventListener].
///
/// New events are added over time, so code that switches over [name] needs a default case.
///
class IaSdkLoggedAnalyticsEvent {
  /// Constructs a new instance of the [IaSdkLoggedAnalyticsEvent] object.
  ///
  const IaSdkLoggedAnalyticsEvent({
    required this.name,
    required this.parameters,
  });

  /// Name of the event, one of [IaSdkAnalyticsEventNames], for example `screen_view`, `add_to_cart`, `purchase` or
  /// `pharmacy_selected`.
  ///
  final String name;

  /// Values of the event, keyed by [IaSdkAnalyticsParameterNames], for example `screen_name` or `transaction_id`.
  /// Empty for events without values.
  ///
  /// On Android every value is a `String`, and a parameter without a value is absent. No price or order value is
  /// included.
  ///
  final Map<String, dynamic> parameters;

  /// The event as `{"name":…,"parameters":{…}}`, the format the native SDKs use. An event without parameters has no
  /// `parameters` key.
  ///
  String toJson() {
    return jsonEncode({
      'name': name,
      if (parameters.isNotEmpty) 'parameters': parameters,
    });
  }

  @override
  String toString() => 'IaSdkLoggedAnalyticsEvent(${toJson()})';
}
