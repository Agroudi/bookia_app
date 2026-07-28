import 'package:bookia_app/core/api/api_client.dart';
import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/models/paginated.dart';
import 'package:bookia_app/features/orders/data/models/order_model.dart';

class OrdersService {
  const OrdersService(this._client);

  final ApiClient _client;

  /// The pre-submit summary: cart total plus whatever address the server
  /// already has on file.
  Future<ApiResult<CheckoutModel>> checkout() => _client.get(
    ApiConstants.checkout,
    parse: (data) => CheckoutModel.fromJson(Parse.object(data)),
  );

  /// Returns just the new order's id.
  Future<ApiResult<int>> placeOrder({
    required int governorateId,
    required String name,
    required String phone,
    required String address,
    required String email,
  }) => _client.post(
    ApiConstants.placeOrder,
    body: {
      ApiKeys.governorateId: governorateId,
      ApiKeys.name: name,
      ApiKeys.phone: phone,
      ApiKeys.address: address,
      ApiKeys.email: email,
    },
    parse: (data) => Parse.object(data)['id'] as int? ?? 0,
  );

  Future<ApiResult<Paginated<OrderSummary>>> history({int page = 1}) =>
      _client.get(
        ApiConstants.orderHistory,
        query: {'page': page},
        parse: (data) => OrderSummary.pageFrom(Parse.object(data)),
      );

  Future<ApiResult<OrderDetails>> order(int id) => _client.get(
    ApiConstants.order(id),
    parse: (data) => OrderDetails.fromJson(Parse.object(data)),
  );

  Future<ApiResult<List<GovernorateModel>>> governorates() => _client.get(
    ApiConstants.governorates,
    parse: (data) =>
        Parse.objectList(data).map(GovernorateModel.fromJson).toList(),
  );
}

abstract interface class OrdersRepository {
  Future<ApiResult<CheckoutModel>> checkout();
  Future<ApiResult<int>> placeOrder({
    required int governorateId,
    required String name,
    required String phone,
    required String address,
    required String email,
  });
  Future<ApiResult<Paginated<OrderSummary>>> history({int page});
  Future<ApiResult<OrderDetails>> order(int id);
  Future<ApiResult<List<GovernorateModel>>> governorates();
}

class OrdersRepo implements OrdersRepository {
  const OrdersRepo(this._service);

  final OrdersService _service;

  @override
  Future<ApiResult<CheckoutModel>> checkout() => _service.checkout();

  @override
  Future<ApiResult<int>> placeOrder({
    required int governorateId,
    required String name,
    required String phone,
    required String address,
    required String email,
  }) => _service.placeOrder(
    governorateId: governorateId,
    name: name,
    phone: phone,
    address: address,
    email: email,
  );

  @override
  Future<ApiResult<Paginated<OrderSummary>>> history({int page = 1}) =>
      _service.history(page: page);

  @override
  Future<ApiResult<OrderDetails>> order(int id) => _service.order(id);

  @override
  Future<ApiResult<List<GovernorateModel>>> governorates() =>
      _service.governorates();
}
