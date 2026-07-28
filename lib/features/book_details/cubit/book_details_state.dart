part of 'book_details_cubit.dart';

class BookDetailsState {
  const BookDetailsState({
    this.status = LoadStatus.initial,
    this.product,
    this.failure,
  });

  final LoadStatus status;
  final ProductModel? product;
  final AppFailure? failure;

  BookDetailsState copyWith({
    LoadStatus? status,
    ProductModel? product,
    AppFailure? failure,
    bool clearFailure = false,
  }) => BookDetailsState(
    status: status ?? this.status,
    product: product ?? this.product,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}
