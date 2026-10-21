part of '../../impl.dart';

class _RequestModelSetMocks implements IaBaseRequest {
  _RequestModelSetMocks({
    required this.mocks,
  });

  final IaCardLinkMocks mocks;

  @override
  Map<String, dynamic> toSupportedType() {
    return mocks.toJson();
  }
}
