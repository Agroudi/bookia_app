import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/api/load_status.dart';
import 'package:bookia_app/core/models/paginated.dart';
import 'package:bookia_app/features/orders/data/models/order_model.dart';
import 'package:bookia_app/features/orders/data/orders_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'orders_state.dart';

/// Drives Order History, Order Details, and the Place Order flow.
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repo) : super(const OrdersState());

  final OrdersRepository _repo;

  bool _isBusy = false;

  Future<void> loadHistory({bool isRefresh = false}) async {
    if (isClosed || _isBusy) return;
    _isBusy = true;

    emit(
      state.copyWith(
        status: isRefresh ? LoadStatus.refreshing : LoadStatus.loading,
        clearFailure: true,
      ),
    );

    try {
      switch (await _repo.history()) {
        case ApiSuccess(:final data):
          emit(state.copyWith(status: LoadStatus.success, orders: data));
        case ApiFailure(:final failure):
          emit(state.copyWith(status: LoadStatus.failure, failure: failure));
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> loadMoreHistory() async {
    if (isClosed || state.isLoadingMore || !state.orders.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));

    final result = await _repo.history(page: state.orders.meta.currentPage + 1);
    if (isClosed) return;

    switch (result) {
      case ApiSuccess(:final data):
        emit(
          state.copyWith(
            orders: state.orders.merge(data),
            isLoadingMore: false,
          ),
        );
      case ApiFailure(:final failure):
        emit(state.copyWith(isLoadingMore: false, failure: failure));
    }
  }

  Future<void> loadOrder(int id) async {
    if (isClosed) return;
    emit(
      state.copyWith(
        detailsStatus: LoadStatus.loading,
        clearFailure: true,
        clearDetails: true,
      ),
    );

    switch (await _repo.order(id)) {
      case ApiSuccess(:final data):
        if (!isClosed) {
          emit(
            state.copyWith(detailsStatus: LoadStatus.success, details: data),
          );
        }
      case ApiFailure(:final failure):
        if (!isClosed) {
          emit(
            state.copyWith(detailsStatus: LoadStatus.failure, failure: failure),
          );
        }
    }
  }

  /// Loads the checkout summary and the governorate list together — the
  /// Place Order form needs both before it can be filled in.
  Future<void> loadCheckout() async {
    if (isClosed || _isBusy) return;
    _isBusy = true;
    emit(
      state.copyWith(checkoutStatus: LoadStatus.loading, clearFailure: true),
    );

    try {
      final results = await Future.wait([
        _repo.checkout(),
        _repo.governorates(),
      ]);
      if (isClosed) return;

      final checkout = results[0] as ApiResult<CheckoutModel>;
      final governorates = results[1] as ApiResult<List<GovernorateModel>>;

      if (checkout case ApiFailure(:final failure)) {
        emit(
          state.copyWith(checkoutStatus: LoadStatus.failure, failure: failure),
        );
        return;
      }

      emit(
        state.copyWith(
          checkoutStatus: LoadStatus.success,
          checkout: checkout.dataOrNull,
          // A missing governorate list is recoverable: the form can still be
          // filled in, it just cannot be submitted until the picker loads.
          governorates: governorates.dataOrNull ?? const [],
        ),
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<void> placeOrder({
    required int governorateId,
    required String name,
    required String phone,
    required String address,
    required String email,
  }) async {
    if (isClosed || _isBusy) return;
    _isBusy = true;
    emit(state.copyWith(submitStatus: LoadStatus.loading, clearFailure: true));

    try {
      final result = await _repo.placeOrder(
        governorateId: governorateId,
        name: name,
        phone: phone,
        address: address,
        email: email,
      );
      if (isClosed) return;

      switch (result) {
        case ApiSuccess(:final data, :final message):
          emit(
            state.copyWith(
              submitStatus: LoadStatus.success,
              placedOrderId: data,
              message: message,
            ),
          );
        case ApiFailure(:final failure):
          emit(
            state.copyWith(submitStatus: LoadStatus.failure, failure: failure),
          );
      }
    } finally {
      _isBusy = false;
    }
  }
}
