part of '../../core.dart';

/// Analytics event tracked by the SDK, reported through [IaSdk.analyticsEventListener].
///
class IaSdkAnalyticsEvent {
  /// Constructs a new instance of the [IaSdkAnalyticsEvent] object.
  ///
  const IaSdkAnalyticsEvent({
    required this.type,
    required this.eventId,
    required this.sessionId,
    required this.timestamp,
    required this.parameters,
  });

  /// Kind of event: `screenView`, `screenExit`, `userAction`, `lifecycle`, `ecommerce`, `engagement` or `derived`.
  ///
  final String type;

  /// Unique identifier of the event.
  ///
  final String eventId;

  /// Identifier of the analytics session the event belongs to.
  ///
  final String sessionId;

  /// Event timestamp as reported by the SDK.
  ///
  final int timestamp;

  /// Values specific to the event [type], for example `screenName`, `eventName`, `items` or `properties`.
  ///
  final Map<String, dynamic> parameters;
}
