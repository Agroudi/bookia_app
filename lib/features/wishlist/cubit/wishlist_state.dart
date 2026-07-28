part of 'wishlist_cubit.dart';

enum WishlistMutation { none, added, removed }

class WishlistState {
  const WishlistState({
    this.status = LoadStatus.initial,
    this.items = const [],
    this.mutation = WishlistMutation.none,
    this.message,
    this.failure,
    this.pendingId,
  });

  final LoadStatus status;
  final List<ProductModel> items;
  final WishlistMutation mutation;
  final String? message;
  final AppFailure? failure;

  /// The product currently being toggled, so its bookmark can show a spinner.
  final int? pendingId;

  bool get isEmpty => items.isEmpty;

  WishlistState copyWith({
    LoadStatus? status,
    List<ProductModel>? items,
    WishlistMutation? mutation,
    String? message,
    AppFailure? failure,
    int? pendingId,
    bool clearFailure = false,
  }) => WishlistState(
    status: status ?? this.status,
    items: items ?? this.items,
    mutation: mutation ?? WishlistMutation.none,
    message: message,
    failure: clearFailure ? null : (failure ?? this.failure),
    pendingId: pendingId,
  );
}
