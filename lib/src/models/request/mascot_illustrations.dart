part of '../../core.dart';

class _RequestModelSetShouldShowMascotIllustrations implements IaBaseRequest {
  _RequestModelSetShouldShowMascotIllustrations({
    required this.shouldShowMascotIllustrations,
  });

  final bool shouldShowMascotIllustrations;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'shouldShowMascotIllustrations': shouldShowMascotIllustrations,
    };
  }
}
