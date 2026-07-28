import 'package:bookia_app/core/api/api_client.dart';
import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/models/product_model.dart';

/// Remote data source for the wishlist.
class WishlistService {
  const WishlistService(this._client);

  final ApiClient _client;

  Future<ApiResult<List<ProductModel>>> wishlist() => _client.get(
    ApiConstants.wishlist,
    parse: (data) => ProductModel.listFrom(
      Parse.listMaybeNested(data, Parse.productListKeys),
    ),
  );

  /// Both mutations return the *whole* updated wishlist, so callers can
  /// replace their state rather than patch it.
  Future<ApiResult<List<ProductModel>>> add(int productId) => _client.post(
    ApiConstants.addToWishlist,
    body: {ApiKeys.productId: productId},
    parse: (data) => ProductModel.listFrom(
      Parse.listMaybeNested(data, Parse.productListKeys),
    ),
  );

  Future<ApiResult<List<ProductModel>>> remove(int productId) => _client.post(
    ApiConstants.removeFromWishlist,
    body: {ApiKeys.productId: productId},
    parse: (data) => ProductModel.listFrom(
      Parse.listMaybeNested(data, Parse.productListKeys),
    ),
  );
}

abstract interface class WishlistRepository {
  Future<ApiResult<List<ProductModel>>> wishlist();
  Future<ApiResult<List<ProductModel>>> add(int productId);
  Future<ApiResult<List<ProductModel>>> remove(int productId);
}

class WishlistRepo implements WishlistRepository {
  const WishlistRepo(this._service);

  final WishlistService _service;

  @override
  Future<ApiResult<List<ProductModel>>> wishlist() => _service.wishlist();

  @override
  Future<ApiResult<List<ProductModel>>> add(int productId) =>
      _service.add(productId);

  @override
  Future<ApiResult<List<ProductModel>>> remove(int productId) =>
      _service.remove(productId);
}
