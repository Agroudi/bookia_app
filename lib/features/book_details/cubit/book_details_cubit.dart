import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/api/load_status.dart';
import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/features/home/data/repo/catalog_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'book_details_state.dart';

/// Loads one product.
///
/// Adding to cart and toggling the wishlist stay with [CartCubit] and
/// [WishlistCubit] — this cubit is only responsible for the book itself, so
/// the details screen and the rest of the app cannot disagree about what is
/// saved or in the basket.
class BookDetailsCubit extends Cubit<BookDetailsState> {
  BookDetailsCubit(this._repo) : super(const BookDetailsState());

  final CatalogRepository _repo;

  /// [preview] is whatever the list screen already had — enough to paint the
  /// cover, title and price immediately while the full record loads.
  Future<void> load(int id, {ProductModel? preview}) async {
    if (isClosed) return;

    emit(
      state.copyWith(
        status: preview == null ? LoadStatus.loading : LoadStatus.refreshing,
        product: preview,
        clearFailure: true,
      ),
    );

    final result = await _repo.product(id);
    if (isClosed) return;

    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: LoadStatus.success, product: data));
      case ApiFailure(:final failure):
        emit(
          state.copyWith(
            // With a preview on screen there is something to look at, so a
            // failed refresh should not replace it with an error page.
            status: state.product == null
                ? LoadStatus.failure
                : LoadStatus.success,
            failure: failure,
          ),
        );
    }
  }
}
