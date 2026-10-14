part of '../../impl.dart';

class _RequestModelGetCartDetails implements IaBaseRequest {
  _RequestModelGetCartDetails({
    required this.allowCached,
    required this.shouldEmitCartUpdate,
  });

  final bool allowCached;

  final bool shouldEmitCartUpdate;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'allowCached': allowCached,
      'shouldEmitCartUpdate': shouldEmitCartUpdate,
    };
  }
}
