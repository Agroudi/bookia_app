import 'package:bookia_app/core/models/json_reader.dart';

/// A banner in the home carousel.
///
/// `/sliders` returns `{"data": {"sliders": [{"image": "..."}]}}` — the image
/// URL is the only field.
class SliderModel {
  const SliderModel({required this.image});

  final String image;

  factory SliderModel.fromJson(Map<String, dynamic> json) =>
      SliderModel(image: json.readString('image') ?? '');

  /// Unwraps the nested `sliders` array, dropping entries with no usable URL.
  static List<SliderModel> listFrom(Map<String, dynamic> data) => data
      .readObjectList('sliders')
      .map(SliderModel.fromJson)
      .where((slider) => slider.image.isNotEmpty)
      .toList();
}
