part of 'home_cubit.dart';

class HomeState {
  const HomeState({
    this.status = LoadStatus.initial,
    this.sliders = const [],
    this.bestSellers = const [],
    this.newArrivals = const [],
    this.failure,
  });

  final LoadStatus status;
  final List<SliderModel> sliders;
  final List<ProductModel> bestSellers;
  final List<ProductModel> newArrivals;

  /// Set only when *every* section failed.
  final AppFailure? failure;

  bool get hasContent =>
      sliders.isNotEmpty || bestSellers.isNotEmpty || newArrivals.isNotEmpty;

  HomeState copyWith({
    LoadStatus? status,
    List<SliderModel>? sliders,
    List<ProductModel>? bestSellers,
    List<ProductModel>? newArrivals,
    AppFailure? failure,
    bool clearFailure = false,
  }) => HomeState(
    status: status ?? this.status,
    sliders: sliders ?? this.sliders,
    bestSellers: bestSellers ?? this.bestSellers,
    newArrivals: newArrivals ?? this.newArrivals,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}
