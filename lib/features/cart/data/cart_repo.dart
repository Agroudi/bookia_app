import 'package:bookia_app/core/api/api_client.dart';
import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/features/cart/data/models/cart_model.dart';

/// Remote data source for the cart.
///
/// Every endpoint here answers with the complete cart, which is why there is
/// no local total arithmetic anywhere in the feature.
class CartService {
  const CartService(this._client);

  final ApiClient _client;

  Future<ApiResult<CartModel>> cart() =>
      _client.get(ApiConstants.cart, parse: _parseCart);

  Future<ApiResult<CartModel>> add(int productId) => _client.post(
    ApiConstants.addToCart,
    body: {ApiKeys.productId: productId},
    parse: _parseCart,
  );

  /// [cartItemId] is the cart *line* id (`item_id`), not the product id.
  Future<ApiResult<CartModel>> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) => _client.post(
    ApiConstants.updateCart,
    body: {ApiKeys.cartItemId: cartItemId, ApiKeys.quantity: quantity},
    parse: _parseCart,
  );

  Future<ApiResult<CartModel>> remove(int cartItemId) => _client.post(
    ApiConstants.removeFromCart,
    body: {ApiKeys.cartItemId: cartItemId},
    parse: _parseCart,
  );

  static CartModel _parseCart(Object? data) =>
      CartModel.fromJson(Parse.object(data));
}

abstract interface class CartRepository {
  Future<ApiResult<CartModel>> cart();
  Future<ApiResult<CartModel>> add(int productId);
  Future<ApiResult<CartModel>> updateQuantity({
    required int cartItemId,
    required int quantity,
  });
  Future<ApiResult<CartModel>> remove(int cartItemId);
}

class CartRepo implements CartRepository {
  const CartRepo(this._service);

  final CartService _service;

  @override
  Future<ApiResult<CartModel>> cart() => _service.cart();

  @override
  Future<ApiResult<CartModel>> add(int productId) => _service.add(productId);

  @override
  Future<ApiResult<CartModel>> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) => _service.updateQuantity(cartItemId: cartItemId, quantity: quantity);

  @override
  Future<ApiResult<CartModel>> remove(int cartItemId) =>
      _service.remove(cartItemId);
}
