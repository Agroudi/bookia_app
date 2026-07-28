part of 'cart_cubit.dart';

/// What just happened to the cart, so a listener can toast the right thing
/// without inspecting the payload.
enum CartMutation { none, adding, added, updating, updated, removing, removed }

class CartState {
  const CartState({
    this.status = LoadStatus.initial,
    this.cart = const CartModel.empty(),
    this.mutation = CartMutation.none,
    this.message,
    this.failure,
  });

  final LoadStatus status;
  final CartModel cart;
  final CartMutation mutation;

  /// The server's confirmation for the last mutation ("Cart Updated").
  final String? message;

  final AppFailure? failure;

  int get itemCount => cart.itemCount;
  double get total => cart.total;
  bool get isEmpty => cart.isEmpty;

  CartState copyWith({
    LoadStatus? status,
    CartModel? cart,
    CartMutation? mutation,
    String? message,
    AppFailure? failure,
    bool clearFailure = false,
  }) => CartState(
    status: status ?? this.status,
    cart: cart ?? this.cart,
    mutation: mutation ?? CartMutation.none,
    message: message,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}
