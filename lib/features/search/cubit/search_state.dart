part of 'search_cubit.dart';

class SearchState {
  const SearchState({
    this.status = LoadStatus.initial,
    this.query = '',
    this.results = const Paginated<ProductModel>.empty(),
    this.isLoadingMore = false,
    this.failure,
  });

  final LoadStatus status;
  final String query;
  final Paginated<ProductModel> results;

  /// Distinct from [status]: appending a page must not blank the list.
  final bool isLoadingMore;

  final AppFailure? failure;

  List<ProductModel> get items => results.items;

  /// The search ran and genuinely found nothing — as opposed to not having
  /// run yet, which is the idle state.
  bool get isEmptyResult =>
      status.isSuccess && query.isNotEmpty && results.isEmpty;

  bool get isIdle => query.isEmpty && status == LoadStatus.initial;

  SearchState copyWith({
    LoadStatus? status,
    String? query,
    Paginated<ProductModel>? results,
    bool? isLoadingMore,
    AppFailure? failure,
    bool clearFailure = false,
  }) => SearchState(
    status: status ?? this.status,
    query: query ?? this.query,
    results: results ?? this.results,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}
