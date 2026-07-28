import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/api/load_status.dart';
import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/features/home/data/models/slider_model.dart';
import 'package:bookia_app/features/home/data/repo/catalog_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repo) : super(const HomeState());

  final CatalogRepository _repo;

  /// Loads the three home sections together.
  ///
  /// They are independent, so they are fetched concurrently and a failure in
  /// one does not blank the others — a missing banner should not cost the user
  /// the book grid.
  Future<void> load({bool isRefresh = false}) async {
    if (isClosed) return;
    if (state.status.isLoading || state.status.isRefreshing) return;

    emit(
      state.copyWith(
        status: isRefresh ? LoadStatus.refreshing : LoadStatus.loading,
        clearFailure: true,
      ),
    );

    final results = await Future.wait([
      _repo.sliders(),
      _repo.bestSellers(),
      _repo.newArrivals(),
    ]);

    if (isClosed) return;

    final sliders = results[0] as ApiResult<List<SliderModel>>;
    final bestSellers = results[1] as ApiResult<List<ProductModel>>;
    final newArrivals = results[2] as ApiResult<List<ProductModel>>;

    // Only a total failure is a failure: if any section loaded, show the page.
    final anySucceeded =
        sliders.isSuccess || bestSellers.isSuccess || newArrivals.isSuccess;

    emit(
      state.copyWith(
        status: anySucceeded ? LoadStatus.success : LoadStatus.failure,
        sliders: sliders.dataOrNull ?? state.sliders,
        bestSellers: bestSellers.dataOrNull ?? state.bestSellers,
        newArrivals: newArrivals.dataOrNull ?? state.newArrivals,
        failure: anySucceeded ? null : _firstFailure(results),
        clearFailure: anySucceeded,
      ),
    );
  }

  AppFailure? _firstFailure(List<ApiResult<Object?>> results) {
    for (final result in results) {
      if (result case ApiFailure(:final failure)) return failure;
    }
    return null;
  }
}
