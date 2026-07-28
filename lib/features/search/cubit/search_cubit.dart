import 'dart:async';

import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/api/load_status.dart';
import 'package:bookia_app/core/models/paginated.dart';
import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/features/home/data/repo/catalog_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repo) : super(const SearchState());

  final CatalogRepository _repo;

  Timer? _debounce;
  CancelToken? _inFlight;

  /// Wait this long after the last keystroke before hitting the API. Turns a
  /// 12-character query into one request instead of twelve.
  static const Duration _debounceDelay = Duration(milliseconds: 450);

  /// Below this, results are meaningless and the request is pure load.
  static const int _minQueryLength = 2;

  void onQueryChanged(String raw) {
    final query = Validators.sanitize(raw, maxLength: Validators.maxSearch);

    _debounce?.cancel();

    if (query.length < _minQueryLength) {
      // Abandon anything already running: its results are for a query the
      // user has since backspaced away from.
      _cancelInFlight();
      emit(const SearchState());
      return;
    }

    if (query == state.query && state.status.isSuccess) return;

    emit(state.copyWith(query: query, status: LoadStatus.loading));
    _debounce = Timer(_debounceDelay, () => _search(query));
  }

  Future<void> _search(String query) async {
    _cancelInFlight();
    final token = CancelToken();
    _inFlight = token;

    final result = await _repo.search(query: query, cancelToken: token);
    if (isClosed || token.isCancelled) return;
    // A newer query started while this was in flight; discard the stale answer.
    if (query != state.query) return;

    switch (result) {
      case ApiSuccess(:final data):
        emit(
          state.copyWith(
            status: LoadStatus.success,
            results: data,
            clearFailure: true,
          ),
        );
      case ApiFailure(:final failure):
        emit(state.copyWith(status: LoadStatus.failure, failure: failure));
    }
  }

  /// Loads the next page. No-ops when already loading or at the last page.
  Future<void> loadMore() async {
    if (isClosed || state.isLoadingMore || !state.results.hasMore) return;
    if (state.query.length < _minQueryLength) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await _repo.search(
      query: state.query,
      page: state.results.meta.currentPage + 1,
    );
    if (isClosed) return;

    switch (result) {
      case ApiSuccess(:final data):
        emit(
          state.copyWith(
            results: state.results.merge(data),
            isLoadingMore: false,
          ),
        );
      case ApiFailure(:final failure):
        emit(state.copyWith(isLoadingMore: false, failure: failure));
    }
  }

  void clear() {
    _debounce?.cancel();
    _cancelInFlight();
    emit(const SearchState());
  }

  void _cancelInFlight() {
    if (_inFlight?.isCancelled == false) {
      _inFlight!.cancel('superseded by a newer query');
    }
    _inFlight = null;
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _cancelInFlight();
    return super.close();
  }
}
