import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/api/load_status.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:bookia_app/features/cart/data/cart_repo.dart';
import 'package:bookia_app/features/cart/data/models/cart_model.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cart_state.dart';

/// Owns the cart for the whole app.
///
/// Provided above the layout rather than per screen, so the nav badge, the
/// Book Details "Add To Cart" button and the Cart tab all read the same
/// state and stay in step without refetching.
class CartCubit extends Cubit<CartState> {
  CartCubit({required CartRepository repo, required SessionStorage storage})
    : _repo = repo,
      _storage = storage,
      super(const CartState());

  final CartRepository _repo;
  final SessionStorage _storage;

  /// Line ids with a mutation in flight. Keyed rather than a single flag so
  /// two different rows can be adjusted at once, while a single row cannot be
  /// double-tapped into sending two conflicting quantities.
  final Set<int> _pendingItems = {};

  /// Guards `add`, which is keyed by product rather than by line.
  final Set<int> _pendingProducts = {};

  bool isItemBusy(int cartItemId) => _pendingItems.contains(cartItemId);
  bool isProductBusy(int productId) => _pendingProducts.contains(productId);

  Future<void> load({bool isRefresh = false}) async {
    // The cart is per-user; there is nothing to fetch when signed out.
    if (!_storage.isLoggedIn) {
      emit(const CartState(status: LoadStatus.success));
      return;
    }
    if (isClosed || state.status.isLoading) return;

    emit(
      state.copyWith(
        status: isRefresh ? LoadStatus.refreshing : LoadStatus.loading,
        clearFailure: true,
      ),
    );

    _emitResult(await _repo.cart());
  }

  /// Adds one unit of [productId]. Returns true when the server accepted it,
  /// so the caller can decide whether to toast or navigate.
  Future<bool> add(int productId) async {
    if (!_storage.isLoggedIn) {
      _emitFailure(
        UnauthorizedFailure(message: LocaleKeys.login_required_message.tr()),
      );
      return false;
    }
    if (_pendingProducts.contains(productId)) return false;

    _pendingProducts.add(productId);
    emit(state.copyWith(mutation: CartMutation.adding));
    try {
      final result = await _repo.add(productId);
      // Clear the pending flag *before* emitting: the widgets read it during
      // the rebuild that this emit triggers, so removing it afterwards would
      // leave the button spinning until some unrelated state change.
      _pendingProducts.remove(productId);
      _emitResult(result, mutation: CartMutation.added);
      return result.isSuccess;
    } finally {
      _pendingProducts.remove(productId);
    }
  }

  /// Sets an absolute quantity, clamped to `[1, stock]`.
  ///
  /// Clamping here rather than in the widget means the rule holds however the
  /// stepper is driven, and stops a user pushing an order past what the shop
  /// actually has.
  Future<void> setQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    if (_pendingItems.contains(cartItemId)) return;

    final item = state.cart.itemById(cartItemId);
    if (item == null) return;

    final maxQuantity = item.stock ?? quantity;
    final clamped = quantity.clamp(1, maxQuantity < 1 ? 1 : maxQuantity);

    if (clamped == item.quantity) {
      // Already at the boundary — tell the user why nothing happened.
      if (quantity > item.quantity) {
        _emitFailure(
          UnknownFailure(message: LocaleKeys.max_quantity_reached.tr()),
        );
      }
      return;
    }

    _pendingItems.add(cartItemId);
    emit(state.copyWith(mutation: CartMutation.updating));
    try {
      final result = await _repo.updateQuantity(
        cartItemId: cartItemId,
        quantity: clamped,
      );
      _pendingItems.remove(cartItemId);
      _emitResult(result, mutation: CartMutation.updated);
    } finally {
      _pendingItems.remove(cartItemId);
    }
  }

  Future<void> increment(int cartItemId) {
    final item = state.cart.itemById(cartItemId);
    if (item == null) return Future.value();
    return setQuantity(cartItemId: cartItemId, quantity: item.quantity + 1);
  }

  Future<void> decrement(int cartItemId) {
    final item = state.cart.itemById(cartItemId);
    if (item == null) return Future.value();
    // At one, the stepper stops; removing is an explicit, confirmed action.
    if (item.quantity <= 1) return Future.value();
    return setQuantity(cartItemId: cartItemId, quantity: item.quantity - 1);
  }

  Future<void> remove(int cartItemId) async {
    if (_pendingItems.contains(cartItemId)) return;

    _pendingItems.add(cartItemId);
    emit(state.copyWith(mutation: CartMutation.removing));
    try {
      final result = await _repo.remove(cartItemId);
      _pendingItems.remove(cartItemId);
      _emitResult(result, mutation: CartMutation.removed);
    } finally {
      _pendingItems.remove(cartItemId);
    }
  }

  /// Drops local state on sign-out so the next user never sees the previous
  /// one's cart.
  void clear() => emit(const CartState(status: LoadStatus.success));

  void _emitResult(
    ApiResult<CartModel> result, {
    CartMutation mutation = CartMutation.none,
  }) {
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data, :final message):
        emit(
          state.copyWith(
            status: LoadStatus.success,
            cart: data,
            mutation: mutation,
            message: message,
            clearFailure: true,
          ),
        );
      case ApiFailure(:final failure):
        emit(
          state.copyWith(
            // Keep whatever is on screen if we already had a cart; only a
            // cold load failing should show the error state.
            status: state.cart.isEmpty
                ? LoadStatus.failure
                : LoadStatus.success,
            mutation: CartMutation.none,
            failure: failure,
          ),
        );
    }
  }

  void _emitFailure(AppFailure failure) {
    if (isClosed) return;
    emit(state.copyWith(failure: failure, mutation: CartMutation.none));
  }
}
