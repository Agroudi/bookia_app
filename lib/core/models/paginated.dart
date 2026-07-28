import 'package:bookia_app/core/models/json_reader.dart';

/// The `meta` block that accompanies every list endpoint.
class PaginationMeta {
  const PaginationMeta({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;

  /// `per_page` comes back as a string on `/products-filter` and as an int
  /// everywhere else, hence [JsonReader.readInt].
  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PaginationMeta.empty();
    return PaginationMeta(
      total: json.readInt('total') ?? 0,
      perPage: json.readInt('per_page') ?? 15,
      currentPage: json.readInt('current_page') ?? 1,
      lastPage: json.readInt('last_page') ?? 1,
    );
  }

  const PaginationMeta.empty()
    : total = 0,
      perPage = 15,
      currentPage = 1,
      lastPage = 1;
}

/// A page of [T] plus its metadata.
class Paginated<T> {
  const Paginated({required this.items, required this.meta});

  final List<T> items;
  final PaginationMeta meta;

  bool get isEmpty => items.isEmpty;
  bool get hasMore => meta.hasMore;

  const Paginated.empty()
    : items = const [],
      meta = const PaginationMeta.empty();

  /// Appends the next page, keeping the newer metadata.
  Paginated<T> merge(Paginated<T> next) =>
      Paginated(items: [...items, ...next.items], meta: next.meta);
}
