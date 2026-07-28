import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/api/load_status.dart';
import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:bookia_app/features/wishlist/data/wishlist_repo.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wishlist_state.dart';

/// App-level, like [CartCubit]: the bookmark on Book Details and the Wishlist
/// tab must agree, and neither should have to refetch to find out.
class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit({
    required WishlistRepository repo,
    required SessionStorage storage,
  }) : _repo = repo,
       _storage = storage,
       super(const WishlistState());

  final WishlistRepository _repo;
  final SessionStorage _storage;

  /// Products with a toggle in flight — stops a double tap from adding and
  /// removing in the same breath.
  final Set<int> _pending = {};

  bool isBusy(int productId) => _pending.contains(productId);

  bool contains(int productId) =>
      state.items.any((product) => product.id == productId);

  Future<void> load({bool isRefresh = false}) async {
    if (!_storage.isLoggedIn) {
      emit(const WishlistState(status: LoadStatus.success));
      return;
    }
    if (isClosed || state.status.isLoading) return;

    emit(
      state.copyWith(
        status: isRefresh ? LoadStatus.refreshing : LoadStatus.loading,
        clearFailure: true,
      ),
    );

    _emitResult(await _repo.wishlist());
  }

  /// Adds or removes depending on current membership.
  Future<void> toggle(int productId) async {
    if (!_storage.isLoggedIn) {
      emit(
        state.copyWith(
          failure: UnauthorizedFailure(
            message: LocaleKeys.login_required_message.tr(),
          ),
        ),
      );
      return;
    }
    if (_pending.contains(productId)) return;

    final wasSaved = contains(productId);
    _pending.add(productId);
    emit(state.copyWith(pendingId: productId));

    try {
      final result = wasSaved
          ? await _repo.remove(productId)
          : await _repo.add(productId);
      // Clear the pending flag before emitting, otherwise the bookmark that
      // rebuilds on this emit would still read "busy" and keep spinning.
      _pending.remove(productId);
      _emitResult(
        result,
        mutation: wasSaved ? WishlistMutation.removed : WishlistMutation.added,
      );
    } finally {
      _pending.remove(productId);
    }
  }

  void clear() => emit(const WishlistState(status: LoadStatus.success));

  void _emitResult(
    ApiResult<List<ProductModel>> result, {
    WishlistMutation mutation = WishlistMutation.none,
  }) {
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data, :final message):
        emit(
          WishlistState(
            status: LoadStatus.success,
            items: data,
            mutation: mutation,
            message: message,
          ),
        );
      case ApiFailure(:final failure):
        emit(
          state.copyWith(
            status: state.items.isEmpty
                ? LoadStatus.failure
                : LoadStatus.success,
            failure: failure,
            mutation: WishlistMutation.none,
          ),
        );
    }
  }
}
