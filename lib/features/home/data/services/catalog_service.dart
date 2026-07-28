import 'package:bookia_app/core/api/api_client.dart';
import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/models/paginated.dart';
import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/features/home/data/models/slider_model.dart';
import 'package:dio/dio.dart';

/// Reads the public catalogue: banners, product lists, one product, search.
///
/// Shared by Home, Search and Book Details rather than duplicated per screen —
/// they all read the same three endpoints in different combinations.
class CatalogService {
  const CatalogService(this._client);

  final ApiClient _client;

  Future<ApiResult<List<SliderModel>>> sliders() => _client.get(
    ApiConstants.sliders,
    parse: (data) => SliderModel.listFrom(Parse.object(data)),
  );

  /// The live server nests these under `data.products` even though the
  /// collection records a bare `data` array, so both are accepted.
  Future<ApiResult<List<ProductModel>>> bestSellers() => _client.get(
    ApiConstants.bestSeller,
    parse: (data) => ProductModel.listFrom(
      Parse.listMaybeNested(data, Parse.productListKeys),
    ),
  );

  Future<ApiResult<List<ProductModel>>> newArrivals() => _client.get(
    ApiConstants.newArrivals,
    parse: (data) => ProductModel.listFrom(
      Parse.listMaybeNested(data, Parse.productListKeys),
    ),
  );

  Future<ApiResult<ProductModel>> product(int id) => _client.get(
    ApiConstants.product(id),
    parse: (data) => ProductModel.fromJson(Parse.object(data)),
  );

  /// [cancelToken] lets the search screen abandon an in-flight request when
  /// the query changes, so a slow earlier response can't overwrite a newer one.
  Future<ApiResult<Paginated<ProductModel>>> search({
    required String query,
    int page = 1,
    CancelToken? cancelToken,
  }) => _client.get(
    ApiConstants.searchProducts,
    query: {'name': query, 'page': page},
    cancelToken: cancelToken,
    parse: _parsePage,
  );

  Future<ApiResult<Paginated<ProductModel>>> products({int page = 1}) => _client
      .get(ApiConstants.products, query: {'page': page}, parse: _parsePage);

  static Paginated<ProductModel> _parsePage(Object? data) {
    final object = Parse.object(data);
    return Paginated(
      items: ProductModel.listFrom(
        object['products'] is List
            ? (object['products'] as List)
                  .whereType<Map<String, dynamic>>()
                  .toList()
            : const [],
      ),
      meta: PaginationMeta.fromJson(
        object['meta'] is Map<String, dynamic>
            ? object['meta'] as Map<String, dynamic>
            : null,
      ),
    );
  }
}
